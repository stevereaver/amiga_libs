/*
 * xpkBLZW.library V3.4 (1 Oct 2013) by Bryan Ford
 *
 * Reconstructed from the 1916-byte binary.
 *
 * Unix-`compress`-style LZW XPK sublibrary.  The packer uses a
 * 6-byte-entry open hash {char@0, prefix@2, code@4}, 9..15 bit codes
 * (mode*7/100+9 clamped to 15), prime-ish hash sizes just above 2^bits,
 * MSB-first bit packing into sliding 32-bit windows, a ratio-checkpoint
 * mechanism that emits CLEAR (257) when compression degrades, width-++
 * marker 258, and END (256).  The decoder builds the same {firstchar@0,
 * prevcode*2@2} table with a downward string stack and decodes the
 * three special markers through a V-flag daisy chain.
 *
 * Vectors (word-offset functab):
 *   -6 open, -12 close, -18 expunge, -24 entry stub,
 *   -30 XpksPackerInfo, -36 XpksPackChunk, -42 XpksPackFree,
 *   -48 entry stub (no reset needed), -54 XpksUnpackChunk,
 *   -60 XpksPackFree (shared).
 */

typedef unsigned char  UBYTE;
typedef short          WORD;
typedef unsigned short UWORD;
typedef long           LONG;
typedef unsigned long  ULONG;
typedef void          *APTR;

struct XpkPack {
    UBYTE *xsp_InBuf;       /* 0x00 */
    ULONG  xsp_InLen;       /* 0x04 */
    UBYTE *xsp_OutBuf;      /* 0x08 */
    ULONG  xsp_OutBufLen;   /* 0x0c */
    ULONG  xsp_OutLen;      /* 0x10 */
    ULONG  xsp_pad14[2];    /* 0x14 */
    ULONG  xsp_Mode;        /* 0x1c */
    ULONG  xsp_pad20[5];    /* 0x20..0x33 */
    APTR   xsp_Work;        /* 0x34 cached work buffer  */
    ULONG  xsp_WorkSize;    /* 0x38                     */
};

struct XpkLib {
    APTR   ln_Succ, ln_Pred;
    UBYTE  ln_Type, ln_Pri;
    APTR   ln_Name;
    UBYTE  lib_Flags, lib_pad;
    UWORD  lib_NegSize, lib_PosSize;
    UWORD  lib_Version, lib_Revision;
    APTR   lib_IdString;
    ULONG  lib_Sum;
    UWORD  lib_OpenCnt;
    ULONG  lib_SegList;     /* +34 = dataSize 0x26    */
};

extern APTR xpkinfo;        /* descriptor in the .s file */

/* ---- exec calls ----------------------------------------------------- */
static void ex_freemem(APTR mem, ULONG sz)
{ register APTR __m __asm("a1") = mem; register ULONG __s __asm("d0") = sz;
  __asm volatile("movel 4,%/a6\n\tjsr %/a6@(-210)\n"
      ::"r"(__m),"r"(__s):"a6","d1","a0","cc","memory"); }
static APTR ex_allocmem(ULONG sz, ULONG flags)
{ register ULONG __s __asm("d0") = sz; register ULONG __f __asm("d1") = flags;
  __asm volatile("movel 4,%/a6\n\tjsr %/a6@(-198)\n"
      :"+r"(__s):"r"(__f):"a6","a0","a1","cc","memory");
  return (APTR)__s; }
static void ex_remove(APTR node)
{ register APTR __n __asm("a1") = node;
  __asm volatile("movel 4,%/a6\n\tjsr %/a6@(-252)\n"
      ::"r"(__n):"a6","d0","d1","a0","cc","memory"); }

/* ---- lifecycle ------------------------------------------------------- */

struct XpkLib *LibOpen(struct XpkLib *lib __asm("a6"))
{
    lib->lib_OpenCnt++;
    lib->lib_Flags &= ~8;
    return lib;
}

ULONG LibExpunge(struct XpkLib *lib __asm("a6"));

ULONG LibClose(struct XpkLib *lib __asm("a6"))
{
    if (--lib->lib_OpenCnt == 0 && (lib->lib_Flags & 8))
        return LibExpunge(lib);
    return 0;
}

ULONG LibExpunge(struct XpkLib *lib __asm("a6"))
{
    ULONG seg = 0;
    if (lib->lib_OpenCnt == 0) {
        seg = lib->lib_SegList;
        ex_remove(lib);
        ex_freemem((UBYTE *)lib - lib->lib_NegSize,
                   (ULONG)lib->lib_NegSize + lib->lib_PosSize);
    } else {
        lib->lib_Flags |= 8;
    }
    return seg;
}

/* ---- -30 XpksPackerInfo --------------------------------------------- */
APTR XpksPackerInfo(void) { return &xpkinfo; }

/* ---- -42 XpksPackFree ------------------------------------------------
 * frees the cached work buffer hung off the param block.
 */
void XpksPackFree(struct XpkPack *xp __asm("a0"))
{
    APTR p = xp->xsp_Work;
    if (p) {
        xp->xsp_Work = 0;
        ex_freemem(p, xp->xsp_WorkSize);
    }
}

/* ---- work-buffer ensure (orig 0x132) -----------------------------------
 * param+52 holds a cached buffer + size at +56; reallocs when the
 * request is larger.  Returns buffer or NULL.  (orig also returns 1
 * in a2 when the cached buffer already fits.)
 */
static void *workalloc(struct XpkPack *xp, ULONG need)
{
    APTR buf = xp->xsp_Work;
    if (buf && need >= xp->xsp_WorkSize)
        XpksPackFree(xp);
    if (!xp->xsp_Work) {
        xp->xsp_WorkSize = need;
        xp->xsp_Work = ex_allocmem(need, 0);
        buf = xp->xsp_Work;
    }
    return buf;
}

/* ---- -36 XpksPackChunk -----------------------------------------------
 * Unix-compress LZW.  Hash table of 6-byte entries {chr@0, pfx@2,
 * code@4}; hash = ((c << (bits-8)) ^ pfx) * 6 -- unmasked: the table
 * sizes (641, 1283, 2579, 5147, 10243, 20483, 40961 for 9..15 bits)
 * are primes just over 2^bits so the raw index always fits.
 * Stream: u16 maxwidth, u16 maxlen&~3, then MSB-first bit-packed
 * codes OR-ed into a sliding 32-bit window starting at out+4.
 * Codes: 256 = end, 257 = clear, 258 = width++.
 *
 * Emit bound quirk: the inline emit checks a1 against sp@(4), the
 * real limit (out+(inlen&~31)-8), but the special-code emit sub
 * (orig 0x2ca) checks against sp@(8), which is frame garbage until
 * the first ratio-checkpoint stores the input cursor there.  We
 * model that field as chk_in, initialised to "never fire".
 */

struct HEnt { WORD chr; UWORD pfx; UWORD code; };

static void orbe32(UBYTE *p, ULONG v)
{
    p[0] |= (UBYTE)(v >> 24); p[1] |= (UBYTE)(v >> 16);
    p[2] |= (UBYTE)(v >>  8); p[3] |= (UBYTE) v;
}

/* 68000 divuw: 32-bit dividend / 16-bit divisor -> 16-bit quotient */
static UWORD ex_divuw(ULONG num, UWORD den)
{
#ifdef __mc68000__
    register ULONG __n __asm("d0") = num;
    register UWORD __d __asm("d1") = den;
    __asm volatile("divuw %1,%0" : "+d"(__n) : "d"(__d));
    return (UWORD)__n;
#else
    return (UWORD)(num / den);
#endif
}

LONG XpksPackChunk(struct XpkPack *xp __asm("a0"))
{
    static const UWORD tabsz[7] =
        { 641, 1283, 2579, 5147, 10243, 20483, 40961 };
    UBYTE *in, *out, *a1, *limit;
    UBYTE *chk_in, *chk_out;
    UWORD  chk_ratio;
    LONG   d0, next, h, step, bitcur;
    WORD   d4, depth, maxdepth, width, maxw, shift;
    UWORD  thresh;
    ULONG  tabn, tabbytes, n;
    struct HEnt *tab, *e;
    UBYTE  c;

    /* bits = min(mode*7/100 + 9, 15)  (muluw/divuw semantics) */
    maxw = (WORD)(ex_divuw((ULONG)(UWORD)xp->xsp_Mode * 7, 100) + 9);
    if (maxw >= 15) maxw = 15;

    tabn     = tabsz[maxw - 9];
    tabbytes = tabn * 6;
    tab = workalloc(xp, tabbytes);
    if (!tab) return -7;

    in  = xp->xsp_InBuf;
    out = xp->xsp_OutBuf;
    d0  = (LONG)xp->xsp_InLen;

    /* the original pre-clears out[0 .. inlen&~31) with a backward
     * moveml loop and leaves the writer at out+4; for inlen < 32
     * its dbf counter underflows and it scribbles ~64 MB below the
     * buffer (effectively a crash).  Reproduce the normal case. */
    n = (ULONG)d0 & ~31UL;
    {
        UBYTE *p = out;
        ULONG i = n;
        while (i--) *p++ = 0;
    }
    a1    = out + 4;
    limit = out + n - 8;

    bitcur = 32;
    chk_in = (UBYTE *)-1;         /* sp@(8): uninit until checkpoint */
    chk_out = 0;
    chk_ratio = 0;
    maxdepth = 0;
    shift = (WORD)(maxw - 8);

reinit:
    {
        ULONG i;
        for (i = 0; i < tabn; i++) tab[i].chr = -1;
    }
    next   = 259;
    width  = 9;
    thresh = 512;
    d4 = *in++;
    d0--;
    depth = 4;

    for (;;) {
        if (--d0 < 0) goto flush;
        c = *in++;
        h = (LONG)((((ULONG)c << shift) ^ (UWORD)d4) * 6);

        e = (struct HEnt *)((UBYTE *)tab + h);
        if (e->chr >= 0) {
            if (e->pfx == (UWORD)d4 && e->chr == (WORD)c) goto hit;
            step = h - (LONG)tabbytes + 6;
            h += step; if (h < 0) h += tabbytes;
            for (;;) {
                e = (struct HEnt *)((UBYTE *)tab + h);
                if (e->chr < 0) break;             /* empty -> insert */
                if (e->pfx == (UWORD)d4 && e->chr == (WORD)c) goto hit;
                h += step; if (h < 0) h += tabbytes;
            }
        }

        /* insert (e = empty slot) */
        if (depth >= maxdepth) maxdepth = depth;
        e->code = (UWORD)next;
        if (next < 0) goto overflow;
        e->pfx = (UWORD)d4;
        e->chr = (WORD)c;
        next++;
        if (next >= thresh) {
            if (width == maxw) {
                /* dictionary full at max width: write the width
                 * header, park nextcode at -1 (every later insert
                 * takes the overflow path) and snapshot the ratio
                 * checkpoint. */
                out[0] = 0; out[1] = (UBYTE)maxw;
                next = -1;
                chk_in = in; chk_out = a1; chk_ratio = 0;
                goto emit_pfx;
            }
            if ((UWORD)d4 >= thresh) {
                /* emit 258 = width++ (special emit, chk_in bound) */
                bitcur -= width;
                if (bitcur < 0) {
                    a1 += 2;
                    if (a1 >= chk_in) goto over;
                    bitcur += 16;
                }
                orbe32(a1, (ULONG)258 << bitcur);
                width++;
                thresh <<= 1;
            }
        }
        goto emit_pfx;

hit:
        d4 = (WORD)e->code;
        depth++;
        continue;

overflow:
        /* subq.b on next -- fires the ratio check once per 256
         * failed inserts */
        next = (next & ~0xffL) | ((next - 1) & 0xffL);
        if (next & 0xff) goto emit_pfx;
        {
            WORD ratio = (WORD)ex_divuw((ULONG)(in - chk_in) << 8,
                                        (UWORD)(a1 - chk_out));
            if (ratio >= chk_ratio) {
                /* improving -- move the checkpoint forward */
                chk_in = in; chk_out = a1; chk_ratio = (UWORD)ratio;
                goto emit_pfx;
            }
        }
        if (d0 < 127) goto emit_pfx;
        /* degrading: emit prefix, the literal, then 257 = clear
         * (all through the chk_in-bound emit) and restart */
        bitcur -= width;
        if (bitcur < 0) {
            a1 += 2; if (a1 >= chk_in) goto over; bitcur += 16;
        }
        orbe32(a1, (ULONG)d4 << bitcur);
        bitcur -= width;
        if (bitcur < 0) {
            a1 += 2; if (a1 >= chk_in) goto over; bitcur += 16;
        }
        orbe32(a1, (ULONG)(UBYTE)c << bitcur);
        bitcur -= width;
        if (bitcur < 0) {
            a1 += 2; if (a1 >= chk_in) goto over; bitcur += 16;
        }
        orbe32(a1, (ULONG)257 << bitcur);
        goto reinit;

emit_pfx:
        /* inline emit of d4 -- checked against the real limit */
        bitcur -= width;
        if (bitcur < 0) {
            a1 += 2;
            if (a1 >= limit) goto over;
            bitcur += 16;
        }
        orbe32(a1, (ULONG)d4 << bitcur);
        d4 = (WORD)c;
        depth = 4;
    }

flush:
    if ((UWORD)d4 >= thresh) {
        bitcur -= width;
        if (bitcur < 0) {
            a1 += 2; if (a1 >= chk_in) goto over; bitcur += 16;
        }
        orbe32(a1, (ULONG)258 << bitcur);
        width++;
    }
    bitcur -= width;                        /* last prefix */
    if (bitcur < 0) {
        a1 += 2; if (a1 >= chk_in) goto over; bitcur += 16;
    }
    orbe32(a1, (ULONG)d4 << bitcur);
    bitcur -= width;                        /* 256 = end */
    if (bitcur < 0) {
        a1 += 2; if (a1 >= chk_in) goto over; bitcur += 16;
    }
    orbe32(a1, (ULONG)256 << bitcur);

    a1 += 4;
    {
        WORD m = (WORD)(maxdepth & ~3);
        out[2] = (UBYTE)(m >> 8); out[3] = (UBYTE)m;
        if (!(out[0] | out[1])) {
            out[0] = 0; out[1] = (UBYTE)width;
        }
        xp->xsp_OutLen = (ULONG)(a1 - out);
    }
    return 0;

over:
    return -17;
}

/* ---- -54 XpksUnpackChunk ---------------------------------------------
 * Decodes the stream above.  Work buffer: u8 string stack growing
 * down from buf+maxlen, then a 4-byte-entry table at buf+maxlen:
 *   {firstchar_or_marker@0, prevcode*2@2}
 * Literal entries i hold marker -(256-i); entries 256..258 hold the
 * markers -32768 (end), -32767 (clear), -32766 (width++), dispatched
 * by a V-flag daisy chain (see marker: below).
 * Codes are read MSB-first from the same sliding 32-bit window at
 * in+4; the "remaining" counter d1 gates dictionary writes (dbf
 * semantics: writes while --d1 >= 0).
 */

struct DEnt { WORD f; UWORD prev2; };

static ULONG rdbe32(const UBYTE *p)
{
    return ((ULONG)p[0] << 24) | ((ULONG)p[1] << 16) |
           ((ULONG)p[2] <<  8) |  (ULONG)p[3];
}
static UWORD rdbe16(const UBYTE *p)
{
    return (UWORD)(((UWORD)p[0] << 8) | p[1]);
}

LONG XpksUnpackChunk(struct XpkPack *xp __asm("a0"))
{
    UBYTE *in, *out, *sp, *stack;
    struct DEnt *t, *e, *next;
    LONG   bitcur, freecnt, d1;
    WORD   d3, d4, d5, d6;
    UWORD  maxw, mask;
    LONG   maxlen;
    ULONG  i;

    in    = xp->xsp_InBuf;
    maxw  = rdbe16(in);
    maxlen = (WORD)rdbe16(in + 2);          /* sign-extend moveaw */
    t = workalloc(xp, (4UL << maxw) + (ULONG)maxlen);
    if (!t) return -7;

    out   = xp->xsp_OutBuf;
    bitcur = 32;
    freecnt = (1L << maxw) - 259;

    stack = (UBYTE *)t + maxlen;            /* a5 */
    t     = (struct DEnt *)stack;           /* table overlays tail    */
    sp    = stack;                          /* a4, grows downward     */
    in   += 4;                              /* past the header        */

    for (i = 0; i < 256; i++) t[i].f = (WORD)i - 256;
    t[256].f = -32768;                      /* end      */
    t[257].f = -32767;                      /* clear    */
    t[258].f = -32766;                      /* width++  */
    next = t + 259;                         /* a6 */
    d3 = 9; mask = 511;

restart:                                    /* orig 0x49c */
    d3 = 9; mask = 511; next = t + 259;
    d1 = freecnt;
    /* first code after init/clear: literal, no dict write */
    bitcur -= d3;
    if (bitcur < 0) { in += 2; bitcur += 16; }
    d5 = (WORD)(rdbe32(in) >> bitcur) & mask;
    d4 = (WORD)(d5 * 2);
    d6 = (WORD)(UBYTE)d5;
    *out++ = (UBYTE)d5;
    goto readnext;

writenext:                                  /* orig 0x426 */
    next->f     = d6;
    next->prev2 = (UWORD)d4;
    next++;
setprev:                                    /* orig 0x42a */
    d4 = d5;
readnext:                                   /* orig 0x42c */
    bitcur -= d3;
    if (bitcur < 0) { in += 2; bitcur += 16; }
    {
        ULONG code = (rdbe32(in) >> bitcur) & mask;
        d5 = (WORD)(code * 2);
        e  = (struct DEnt *)((UBYTE *)t + code * 4);
        if (e >= next) {
            /* KwKwK: code == next -- prev string + its first char */
            *--sp = (UBYTE)d6;
            e = (struct DEnt *)((UBYTE *)t + d4 * 2);
        }
        {
            WORD f = e->f;
            if (f < 0) goto marker;
            for (;;) {
                *--sp = (UBYTE)f;
                e = (struct DEnt *)((UBYTE *)t + e->prev2 * 2);
                f = e->f;
                if (f < 0) break;
            }
            /* chain terminated by a literal marker */
            *out++ = (UBYTE)f;
            d6 = (WORD)(UBYTE)f;
            while (sp < stack) *out++ = *sp++;
            goto nextcode;
marker:
            f = (WORD)(f - 3);
            if (f >= 0) {                    /* V set: -32768..-32766 */
                f = (WORD)(f + 1);
                if (f < 0) {                 /* -32766 -> 258 */
                    d3++;
                    mask = (UWORD)(mask * 2 + 1);
                    goto readnext;
                }
                f = (WORD)(f + 1);
                if (f < 0) goto restart;     /* -32767 -> 257 */
                return 0;                    /* -32768 -> 256 */
            }
            /* literal marker -(256-c): emit low byte */
            *out++ = (UBYTE)(WORD)(f + 3);
            d6 = (WORD)(UBYTE)(WORD)(f + 3);
            while (sp < stack) *out++ = *sp++;
        }
    }
nextcode:
    if (--d1 >= 0) goto writenext;
    d1 = 0;
    goto setprev;
}
