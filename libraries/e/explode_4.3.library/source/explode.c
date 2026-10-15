/*
 * explode.library 4.3 - "Executable file exploder" (29 May 1989, (c) DSI)
 *
 * Reconstructed combined decruncher + relocating loader.
 *
 * Format summary (decoded from the shipped binary):
 *  - The packed blob is read BACKWARD from its end; output is likewise
 *    written downward through a ring window that lives in the LAST
 *    hunk's memory.
 *  - Stream = literal runs and LZ matches.  After a match, the next
 *    literal-run length is read (so each block emits prev-literals +
 *    one match).
 *  - Copy-out consumes the ring in 4-byte "records": a negative long
 *    ends the current segment; a long with bit30 set introduces a
 *    relocation group {segidx, count, deltas} which the loader applies
 *    in place; otherwise 4 payload bytes are copied to the segment.
 *  - Bit reader: MSB-first; an all-zero reservoir triggers a refill
 *    that shifts in a 1 sentinel (the "ADDX" trick).
 *
 * Register map from the original (for the asm block comments):
 *   A0 = packed stream cursor (descending)
 *   A2 = ring write cursor, A3 = output segment base, A5 = match src
 *   A6 = ring low bound, D4 = ring size, D5 = segment index,
 *   D0 = match length, D1 = bit reservoir, D2 = literal count,
 *   D3 = distance class, D6/D7 = scratch
 */
#include "explbase.h"

/* LAB_0058: 12-byte packed table - len_base[0..7] then len_bits[0..7] */
static const UBYTE len_tbl[12] = {
    0x06, 0x0a, 0x0a, 0x12, 0x02, 0x03, 0x03, 0x04,
    0x04, 0x05, 0x07, 0x00
};

/* LAB_0059: per-format 12-byte distance-bit tables (formats 0-8 only).
 * Bit 7 marks entries that read one raw byte before the extra bits. */
static const UBYTE off_tbl[9][12] = {
    {0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x06,0x06,0x06,0x06},
    {0x05,0x06,0x07,0x07,0x06,0x06,0x06,0x06,0x07,0x07,0x06,0x06},
    {0x05,0x06,0x07,0x07,0x07,0x07,0x07,0x07,0x80,0x80,0x80,0x80},
    {0x05,0x06,0x07,0x80,0x07,0x07,0x80,0x80,0x80,0x81,0x81,0x81},
    {0x06,0x07,0x07,0x80,0x07,0x80,0x81,0x81,0x80,0x81,0x82,0x82},
    {0x06,0x07,0x07,0x80,0x07,0x81,0x81,0x82,0x80,0x82,0x83,0x83},
    {0x06,0x07,0x07,0x80,0x07,0x81,0x81,0x82,0x80,0x82,0x84,0x84},
    {0x06,0x07,0x07,0x80,0x07,0x81,0x82,0x82,0x80,0x83,0x84,0x85},
    {0x06,0x07,0x07,0x80,0x07,0x81,0x82,0x83,0x80,0x83,0x85,0x86},
};

/* ---- bit reservoir (D1) : MSB first, sentinel refill ---- */
static UWORD getbit(struct ExplodeFrame *f, UBYTE **spp)
{
    UBYTE buf = f->xf_bitbuf;
    UWORD bit = buf >> 7;
    buf <<= 1;
    if (buf == 0) {            /* reservoir drained: refill + sentinel */
        buf = *--(*spp);
        buf = (UBYTE)((buf << 1) | 1);
    }
    f->xf_bitbuf = buf;
    return bit;
}

/* LAB_0055: walk the BPTR chain `index` links, return data ptr (+4) */
UBYTE *explode_chaindata(APTR chain, WORD index)
{
    ULONG *p = (ULONG *)chain;
    while (--index >= 0)
        p = (ULONG *)(*p << 2);     /* BCPL pointer: stored >>2 */
    return (UBYTE *)p + 4;
}

/* LAB_001D setup: tables, stream header, range build, chain walk */
void explode_setup(struct ExplodeFrame *f, UBYTE *hdr, APTR chain)
{
    WORD i;
    UBYTE fmt;

    f->xf_outcount = 0;
    for (i = 0; i < 12; i++)
        f->xf_tbl[i] = len_tbl[i];

    /* stream header (forward reads) */
    f->xf_pending  = 0;
    f->xf_tbl[11]  = hdr[0] >> 4;  /* hi nibble OVERRIDES tbl[11]
                                    (len_bits[7]) - encoder-chosen */
    fmt            = hdr[0] & 0x0f;
    f->xf_bitbuf   = hdr[1];
    f->xf_litcount = ((UWORD *)hdr)[1];
    f->xf_blocks   = *(LONG *)(hdr + 4);
    for (i = 0; i < 12; i++)
        f->xf_offbits[i] = off_tbl[fmt][i];

    /* distance range table: 1<<bits, -1 when block count negative */
    for (i = 0; i < 8; i++) {
        UBYTE b = f->xf_offbits[i];
        UWORD v;
        if (b & 0x80)
            b = (b & 0x7f) + 8;
        v = (UWORD)(1u << b);
        if (f->xf_blocks < 0)
            v--;
        f->xf_range[i] = v;
    }
    /* cumulative: range[4..7] += range[0..3] */
    for (i = 0; i < 4; i++)
        f->xf_range[4 + i] += f->xf_range[i];

    /* count chain links (BPTRs) */
    {
        ULONG *p = (ULONG *)chain;
        WORD n = 0;
        f->xf_chain = chain;
        while (*p) {
            n++;
            p = (ULONG *)(*p << 2);
        }
        f->xf_nsegs = n - 1;
    }
}

/*
 * Decoder context: the original splits registers between the
 * record driver (a2 pull cursor, a3 segbase, d5 segidx) and the
 * ring refill (a3 wpos, a5 match src, d5 space).  A5 (match src)
 * deliberately survives refill calls, so it lives here.
 */
struct dctx {
    struct ExplodeFrame *f;
    UBYTE *src;      /* a0: packed stream, read descending      */
    UBYTE *rcur;     /* a2: ring pull cursor                    */
    UBYTE *rlo;      /* a6: ring low bound                      */
    UWORD  rsz;      /* d4: ring size                           */
    UBYTE *wcur;     /* a3: ring write cursor (refill scope)    */
    WORD   space;    /* d5: ring bytes left      (refill scope) */
    UBYTE *msrc;     /* a5: match source - survives refills     */
    ULONG  len;      /* d0: match length in progress            */
};

/* LAB_002D/002E-0051: refill the ring from the bitstream.
 * Runs until `space` bytes were emitted or the block count ends;
 * saves pending-match state into the frame on exit. */
static void ring_refill(struct dctx *c)
{
    struct ExplodeFrame *f = c->f;
    UBYTE *src = c->src;
    UBYTE *wcur;
    WORD   space;

    ULONG  len = 0;
    UWORD  cls;

    c->rcur += c->rsz;              /* rewind pull cursor to ring top  */
    wcur  = c->rcur;
    space = c->rsz;

    if (f->xf_pending) {            /* resume a match cut mid-copy     */
        len = f->xf_pending - 1;
        goto matchcopy;
    }

    for (;;) {
        /* literal run: xf_litcount bytes straight from the stream */
        while (f->xf_litcount) {
            if (--space < 0)
                goto out;
            *--wcur = *--src;
            f->xf_litcount--;
        }
        if (--f->xf_blocks == 0)
            goto out;

        {
            /* length/class prefix code (LAB_0031-003D) */
            if (!getbit(f, &src))            { len = 2; cls = 0; }
            else if (!getbit(f, &src))       { len = 3; cls = 1; }
            else if (!getbit(f, &src))       { len = 4; cls = 2; }
            else if (!getbit(f, &src))       { len = 5; cls = 3; }
            else if (!getbit(f, &src))       { len = 6; cls = 3;
                                               len += (getbit(f,&src)<<2)
                                                    + (getbit(f,&src)<<1)
                                                    +  getbit(f,&src); }
            else                             { len = *--src; cls = 3; }

            /* next literal-run count (LAB_003E-0046); d2 accumulates */
            {
                UWORD d2 = 0, d6, d7;
                if (!getbit(f, &src)) {
                    d2 = getbit(f, &src);
                } else {
                    if (!getbit(f, &src)) {
                        d6 = 2;
                        d7 = f->xf_tbl[4 + cls];
                    } else {
                        d6 = f->xf_tbl[cls];
                        d7 = f->xf_tbl[8 + cls];
                    }
                    while (d7--)
                        d2 = (UWORD)((d2 << 1) | getbit(f, &src));
                    d2 += d6;
                }
                f->xf_litcount = d2;
            }

            /* distance (LAB_0047-004E) */
            {
                UWORD d6 = 0, d7 = cls;
                LONG  base = 0;
                if (getbit(f, &src)) {
                    if (getbit(f, &src)) {
                        base = f->xf_range[4 + cls];   /* cumulative far */
                        d7 += 8;
                    } else {
                        base = f->xf_range[cls];       /* mid           */
                        d7 += 4;
                    }
                }
                d7 = f->xf_offbits[d7];
                if (d7 & 0x80) {
                    d6 = *--src;
                    d7 &= 0x7f;
                }
                while (d7--)
                    d6 = (UWORD)((d6 << 1) | getbit(f, &src));
                d6++;
                c->msrc = wcur + base + d6;
                if (c->msrc > c->rcur)
                    c->msrc -= c->rsz;
                len--;
                for (;;) {
matchcopy:
                    if (c->msrc == c->rlo)
                        c->msrc = c->rcur;
                    if (--space < 0) {
                        f->xf_pending = (UBYTE)(len + 1);
                        goto out2;
                    }
                    *--wcur = *--c->msrc;
                    if (!len--)
                        break;
                }
            }
        }
    }
out:
    f->xf_pending = 0;
out2:
    c->src  = src;
    c->wcur = wcur;
    c->space = space;
}

/* LAB_002A/002B: pull one long from the ring (refill on drain). */
static ULONG pull4(struct dctx *c, UBYTE *dst)
{
    if (c->rcur == c->rlo)
        ring_refill(c);
    dst[0] = *--c->rcur;
    dst[1] = *--c->rcur;
    dst[2] = *--c->rcur;
    dst[3] = *--c->rcur;
    c->f->xf_outcount += 4;
    return *(ULONG *)dst;
}

/*
 * LAB_0024-0053: copy-out driver.  Consumes tagged 4-byte records
 * from the ring: <0 ends the segment, bit30 -> relocation group,
 * 0 -> skipped, else 4 payload bytes to the segment base.
 * Afterwards frees every staging hunk and returns bytes emitted.
 */
ULONG explode_run(struct ExplodeFrame *f, UBYTE *src, APTR chain,
                  UBYTE *ring_lo, UWORD ring_sz)
{
    struct dctx c;
    LONG  seg;
    UBYTE rec[4];

    c.f = f;  c.src = src;  c.rcur = ring_lo;  c.rlo = ring_lo;
    c.rsz = ring_sz;  c.wcur = ring_lo;  c.space = 0;  c.msrc = NULL;

    for (seg = 0; seg != f->xf_nsegs; ) {
        UBYTE *segbase = explode_chaindata(chain, (WORD)seg);
        for (;;) {
            LONG d0 = (LONG)pull4(&c, rec);
            if (d0 < 0)
                break;
            if (d0 & 0x40000000) {
                /* relocation group: count, target-seg, delta list */
                for (;;) {
                    LONG cnt = (LONG)pull4(&c, rec);
                    UBYTE *tbase;
                    ULONG off = 0;
                    if (!cnt)
                        break;
                    tbase = explode_chaindata(chain,
                                              (WORD)pull4(&c, rec));
                    while (cnt--) {
                        off += pull4(&c, rec);
                        *(ULONG *)(segbase + off) += (ULONG)tbase;
                    }
                }
            } else if (d0 != 0) {
                /* payload long: shipped code stores it at segbase+0
                 * via a ring copy - preserved literally (see findings) */
                *(ULONG *)segbase = (ULONG)d0;
            }
        }
        seg++;
    }
    return f->xf_outcount;
}

/*
 * LAB_001D tail + LAB_0024-0053 driver + teardown.
 *
 * stream = packed blob start (caller return address / seg0+0x20).
 * chain  = stream - 32  (the loaded hunk node table).
 * ring   = last chain node's data area, size = hunk_size - 8.
 * src    = end of second-to-last node's data (stream read backward).
 *          A flag byte at src-23 shifts the start back 4 bytes and
 *          ORs itself into the offset low byte (shipped behaviour).
 * Returns the entry address = chain + 4 (first segment body).
 */
UBYTE *explode_do(struct ExplodeFrame *f, UBYTE *stream)
{
    APTR   chain;
    UBYTE *seg, *src, *rlo;
    LONG   off;
    UWORD  rsz;
    WORD   i;

    chain = stream - 32;
    explode_setup(f, stream, chain);

    rlo = explode_chaindata(chain, f->xf_nsegs + 1);  /* last node    */
    rsz = (UWORD)(*(ULONG *)(rlo - 8) - 8);

    seg = explode_chaindata(chain, f->xf_nsegs);      /* 2nd-to-last  */
    off = *(ULONG *)(seg - 8) - 8;
    src = seg + off;
    if (src[-23]) {
        off = (off - 4) | src[-23];
        src = seg + off;
    }

    explode_run(f, src, chain, rlo, rsz);

    /* LAB_0052/53: free the two staging hunks (ring + stream seg),
     * then clear the link word before the oldest node's data. */
    for (i = f->xf_nsegs + 1; i >= f->xf_nsegs; i--) {
        UBYTE *node = explode_chaindata(chain, i) - 8;
        __FreeMem_base((APTR)4, node, *(ULONG *)node);
    }
    *(ULONG *)(explode_chaindata(chain, f->xf_nsegs - 1) - 4) = 0;

    return (UBYTE *)chain + 4;   /* entry point for the tail-jump   */
}
