/* iff.library 19.1 reconstruction
 *
 * "IFF 19.1 (09-Oct-1990) by Christian A. Weber" — direct
 * descendant of iff.library 16.4.  Adds DecodeAnim (ANIM
 * op-5 DLTA playback into a BitMap) and fixes a pile of
 * 16.4 quirks; a few new ones appear — see okf/findings.
 *
 * Deltas vs 16.4:
 *  - Private data: +34 ExecBase, +38 DOSBase, +42 seglist,
 *    +46 MinList.  ExecBase is cached at init and used for
 *    every exec call (no more abs $0004); ThisTask is read
 *    directly (SysBase+276), FindTask is gone.
 *  - LibOpen allocates the per-task node with MEMF_CLEAR and
 *    the delayed-expunge marker moved to the real lib_Flags
 *    DELEXP bit (+14 bit 3).
 *  - LibInit uses OldOpenLibrary (no version check).
 *  - OpenIFF/NewOpenIFF read formsize-4 body bytes (16.4
 *    over-read by 4).
 *  - FindChunk stops at iff+8+formsize (16.4 scanned 4 bytes
 *    past the real end); FindChunk(iff,0) returns the end
 *    pointer unconditionally.
 *  - GetColorTab masks each gun to its high nibble — the
 *    0x0RGB words are now correct.
 *  - DecodePic: ERR_PLANES(27) gone — planes beyond
 *    bm_Depth decode into a scratch row buffer; rows clamped
 *    to min(bm_Rows, bmhd height); empty BODY yields zero
 *    rows; bmhd depth 0 short-circuits success; plane table
 *    copies 24 pointers (deep-image support).
 *  - ByteRun1 decoder: 0x80 is a proper NOP now.
 *  - GetViewModes masks CAMG chunks with 0xffff9efd.
 *  - Save worker records BMHD left=x*8, top=y (was 0,0);
 *    CMAP count treats depth 24 as 8 (256 pens).
 *  - DecodeAnim: new vector — ANHD op 5 + DLTA into BitMap;
 *    new error codes 29 (no ANHD) / 30 (no DLTA).
 */

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef unsigned long  ULONG;
typedef short          WORD;
typedef long           LONG;
typedef signed char    BYTE;
typedef void          *APTR;
typedef char          *STRPTR;

#ifndef REGPARM_A0
#define REGPARM_A0 __asm("a0")
#define REGPARM_A1 __asm("a1")
#define REGPARM_A2 __asm("a2")
#define REGPARM_A6 __asm("a6")
#define REGPARM_D0 __asm("d0")
#define REGPARM_D1 __asm("d1")
#define REGPARM_D2 __asm("d2")
#define REGPARM_D3 __asm("d3")
#define REGPARM_D4 __asm("d4")
#endif

struct LibData {                    /* after struct Library (+34) */
    APTR   ExecBase;                /* +34 */
    APTR   DOSBase;                 /* +38 */
    APTR   seglist;                 /* +42 */
    ULONG  list[3];                 /* +46: MinList (head/tail/tailpred) */
};

struct OpenNode {                   /* per-task handle, 22 bytes */
    APTR   next, prev;              /* +0,+4 MinNode links */
    UBYTE  pad[6];                  /* +6..+13 */
    APTR   task;                    /* +14 SysBase->ThisTask owner */
    LONG   error;                   /* +18 last IFFError code */
};

/* Amiga BitMap (graphics/gfx.h) */
struct BitMap {
    UWORD  bm_BytesPerRow;          /* +0 */
    UWORD  bm_Rows;                 /* +2 */
    UBYTE  bm_Flags;                /* +4 */
    UBYTE  bm_Depth;                /* +5 */
    UWORD  bm_pad;                  /* +6 */
    APTR   bm_Planes[8];            /* +8 */
};

/* BitMapHeader (BMHD body) */
struct BMHD {
    UWORD  bmh_Width, bmh_Height;   /* +0,+2 */
    WORD   bmh_Left, bmh_Top;       /* +4,+6 */
    UBYTE  bmh_Depth;               /* +8 */
    UBYTE  bmh_Masking;             /* +9 */
    UBYTE  bmh_Compression;         /* +10 */
    UBYTE  bmh_Pad;                 /* +11 */
    UWORD  bmh_Transparent;         /* +12 */
    UBYTE  bmh_XAspect, bmh_YAspect;/* +14,+15 */
    WORD   bmh_PageWidth, bmh_PageHeight; /* +16,+18 */
};

#define ID_FORM 0x464f524dUL        /* 'FORM' */
#define ID_ILBM 0x494c424dUL        /* 'ILBM' */
#define ID_8SVX 0x38535658UL        /* '8SVX' */
#define ID_BMHD 0x424d4844UL        /* 'BMHD' */
#define ID_CMAP 0x434d4150UL        /* 'CMAP' */
#define ID_CAMG 0x43414d47UL        /* 'CAMG' */
#define ID_BODY 0x424f4459UL        /* 'BODY' */
#define ID_ANHD 0x414e4844UL        /* 'ANHD' */
#define ID_DLTA 0x444c5441UL        /* 'DLTA' */

#define MODE_OLDFILE 1005
#define MODE_NEWFILE 1006
#define OFFSET_BEGINNING (-1)

/* error codes (order of appearance in the original) */
#define ERR_OPEN        16
#define ERR_READ        17
#define ERR_NOMEM       18
#define ERR_NOTIFF      19
#define ERR_WRITE       20
#define ERR_NOILBM      24
#define ERR_NOBMHD      25
#define ERR_NOBODY      26
#define ERR_COMPR       28
#define ERR_NOANHD      29          /* new in 19.1 */
#define ERR_NODLTA      30          /* new in 19.1 */
/* ERR_PLANES(27) from 16.4 is no longer produced. */

#define THISTASK(sb) (*(APTR *)((char *)(sb) + 276))

/* ---- exec imports (a6 = ExecBase) ----------------------- */
static inline APTR x_AllocMem(ULONG size, ULONG attr, APTR sb) {
    register APTR r __asm("d0"); register ULONG a0 __asm("d0") = size;
    register ULONG a1 __asm("d1") = attr; register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-198)" : "=r"(r) : "r"(a0),"r"(a1),"r"(a6)
                   : "a0","memory","cc");
    return r;
}
static inline void x_FreeMem(APTR blk, ULONG size, APTR sb) {
    register APTR a1 __asm("a1") = blk; register ULONG a0 __asm("d0") = size;
    register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-210)" :: "r"(a1),"r"(a0),"r"(a6)
                   : "a0","memory","cc");
}
/* ---- dos imports (a6 = DOSBase) ------------------------- */
static inline LONG d_Open(STRPTR name, LONG mode, APTR db) {
    register LONG r __asm("d0"); register STRPTR a1 __asm("d1") = name;
    register LONG a2 __asm("d2") = mode; register APTR a6 __asm("a6") = db;
    __asm volatile("jsr a6@(-30)" : "=r"(r) : "r"(a1),"r"(a2),"r"(a6)
                   : "a0","memory","cc");
    return r;
}
static inline void d_Close(LONG fh, APTR db) {
    register LONG a1 __asm("d1") = fh; register APTR a6 __asm("a6") = db;
    __asm volatile("jsr a6@(-36)" :: "r"(a1),"r"(a6)
                   : "a0","memory","cc");
}
static inline LONG d_Read(LONG fh, APTR buf, LONG len, APTR db) {
    register LONG r __asm("d0"); register LONG a1 __asm("d1") = fh;
    register APTR a2 __asm("d2") = buf; register LONG a3 __asm("d3") = len;
    register APTR a6 __asm("a6") = db;
    __asm volatile("jsr a6@(-42)" : "=r"(r) : "r"(a1),"r"(a2),"r"(a3),"r"(a6)
                   : "a0","memory","cc");
    return r;
}
static inline LONG d_Write(LONG fh, APTR buf, LONG len, APTR db) {
    register LONG r __asm("d0"); register LONG a1 __asm("d1") = fh;
    register APTR a2 __asm("d2") = buf; register LONG a3 __asm("d3") = len;
    register APTR a6 __asm("a6") = db;
    __asm volatile("jsr a6@(-48)" : "=r"(r) : "r"(a1),"r"(a2),"r"(a3),"r"(a6)
                   : "a0","memory","cc");
    return r;
}
static inline void d_Seek(LONG fh, LONG pos, LONG mode, APTR db) {
    register LONG a1 __asm("d1") = fh;
    register LONG a2 __asm("d2") = pos; register LONG a3 __asm("d3") = mode;
    register APTR a6 __asm("a6") = db;
    __asm volatile("jsr a6@(-66)" :: "r"(a1),"r"(a2),"r"(a3),"r"(a6)
                   : "a0","memory","cc");
}
#define LIBD(a6) ((struct LibData *)((char *)(a6) + 34))

/* m68k dbf loop: body runs at least once; repeats until the
 * word counter wraps to -1 (init -1 → 65536 iterations). */
#define DBFLOOP(cnt, body) do { WORD _i = (cnt); \
    do { body; _i = (WORD)(_i - 1); } while (_i != -1); } while (0)

/* dbf-entry loop: counter decremented first, body runs while
 * the result is not -1 — N iterations for N > 0, zero for
 * N == 0, huge wraparound for N < 0, exactly as the CPU does
 * when the dbf sits at the loop entry point. */
#define DBFPRE(cnt, body) do { WORD _i = (cnt); \
    while ((WORD)(--_i) != -1) { body; } } while (0)

/* nostdlib support routines */
LONG __mulsi3(LONG a, LONG b)
{
    LONG r = 0;
    while (b) { if (b & 1) r += a; a <<= 1; b >>= 1; }
    return r;
}
/* ---- per-task error node list --------------------------- */
static struct OpenNode *findnode(struct LibData *ld)
{
    APTR task = THISTASK(ld->ExecBase);
    struct OpenNode *n;
    for (n = (struct OpenNode *)ld->list[0]; n->next;
         n = (struct OpenNode *)n->next)
        if (n->task == task) return n;
    return 0;
}
static LONG clrerr(struct LibData *ld)
{
    struct OpenNode *n = findnode(ld);
    if (n) n->error = 0;
    return 1;
}
static LONG seterr(LONG code, struct LibData *ld)
{
    struct OpenNode *n = findnode(ld);
    if (n) n->error = code;
    return 0;
}
/* ---- OpenIFF / NewOpenIFF ------------------------------- */
static APTR open_worker(STRPTR name, LONG memattr, APTR a6)
{
    struct LibData *ld = LIBD(a6);
    APTR sb = ld->ExecBase, db = ld->DOSBase;
    LONG d5 = 0, fh;
    ULONG hdr[3];
    APTR node = 0;

    fh = d_Open(name, MODE_OLDFILE, db);
    if (!fh) {
        d5 = ERR_OPEN;
    } else {
        d_Read(fh, hdr, 12, db);            /* result ignored */
        if (hdr[0] != ID_FORM) {
            d5 = ERR_NOTIFF;
        } else {
            ULONG attr = (ULONG)memattr;
            if (memattr < 0)
                attr = (hdr[2] == ID_8SVX) ? 3 : 1;
            {
                ULONG size = 12 + hdr[1];
                node = x_AllocMem(size, attr, sb);
                if (!node) {
                    d5 = ERR_NOMEM;
                } else {
                    LONG r;
                    *(ULONG *)node = size;
                    /* 16.4 read hdr[1] bytes here — 4 too
                     * many; 19.1 reads formsize-4.        */
                    r = d_Read(fh, (char *)node + 16,
                               (LONG)hdr[1] - 4, db);
                    if (r < 0) {
                        d5 = ERR_READ;      /* node leaked */
                    } else {
                        ULONG *p = (ULONG *)node + 1;
                        p[0] = hdr[0]; p[1] = hdr[1]; p[2] = hdr[2];
                    };
                };
            };
        };
        d_Close(fh, db);
    };
    if (d5) {
        seterr(d5, ld);
        return 0;
    };
    clrerr(ld);
    return (APTR)((char *)node + 4);
}
APTR OpenIFF(STRPTR name REGPARM_A0, APTR a6 REGPARM_A6)
{
    return open_worker(name, -1, a6);
}
APTR NewOpenIFF(STRPTR name REGPARM_A0, LONG memattr REGPARM_D0,
                APTR a6 REGPARM_A6)
{
    return open_worker(name, memattr, a6);
}
/* ---- CloseIFF ------------------------------------------- */
LONG CloseIFF(APTR iff REGPARM_A1, APTR a6 REGPARM_A6)
{
    if (iff) {
        ULONG *base = (ULONG *)iff - 1;
        x_FreeMem(base, base[0], LIBD(a6)->ExecBase);
    };
    return clrerr(LIBD(a6));
}
/* ---- FindChunk ------------------------------------------ */
/* 19.1 walks iff+12 .. iff+8+formsize — the true end of the
 * chunk area (16.4 overshot by 4).  id == 0 returns the end
 * pointer unconditionally. */
static APTR find_chunk(APTR iff, ULONG id)
{
    ULONG size = ((ULONG *)iff)[1];         /* FORM size */
    UBYTE *end = (UBYTE *)iff + 8 + size;
    UBYTE *p = (UBYTE *)iff + 12;
    if (!id) return end;
    for (;;) {
        ULONG cs;
        if (*(ULONG *)p == id) return p;
        cs = ((ULONG *)p)[1];
        cs = (cs + 1) & ~1UL;
        p += 8 + cs;
        if (p >= end) return 0;
    };
}
APTR FindChunk(APTR iff REGPARM_A1, ULONG id REGPARM_D0,
               APTR a6 REGPARM_A6)
{
    return find_chunk(iff, id);
}
/* ---- GetBMHD -------------------------------------------- */
APTR GetBMHD(APTR iff REGPARM_A1, APTR a6 REGPARM_A6)
{
    APTR c = find_chunk(iff, ID_BMHD);
    if (!c) return (APTR)seterr(ERR_NOBMHD, LIBD(a6));
    clrerr(LIBD(a6));
    return (APTR)((UBYTE *)c + 8);
}
/* ---- GetColorTab ---------------------------------------- */
/* 19.1 masks each gun to its high nibble before packing —
 * produces real 0x0RGB words (16.4 OR'd whole bytes in). */
LONG GetColorTab(APTR iff REGPARM_A1, UWORD *tab REGPARM_A0,
                 APTR a6 REGPARM_A6)
{
    APTR c = find_chunk(iff, ID_CMAP);
    UBYTE *s;
    WORD n, i;
    if (!c) return 0;                       /* no error stored */
    s = (UBYTE *)c + 8;
    n = (WORD)(((WORD)((ULONG *)c)[1]) / 3); /* divs.w #3 */
    for (i = 0; i < n; i++) {
        UWORD r = s[0] & 0xf0;
        UWORD g = s[1] & 0xf0;
        UWORD b = s[2] & 0xf0;
        *tab++ = (UWORD)((r << 4) | g | (b >> 4));
        s += 3;
    };
    return n;
}
/* ---- DecodePic ------------------------------------------ */
/* vanilla copy: entry lands ON the dbf — the count is
 * decremented before the first copy, so exactly rowbytes
 * bytes are copied. */
static void dec_raw(UBYTE **src, UBYTE *dst, WORD rowbytes)
{
    DBFPRE(rowbytes, *dst++ = *(*src)++);
}
/* CmpByteRun1: literal n+1 / replicate -n+1; 0x80 is a NOP
 * (byte negation stays negative → skipped).  Runs are NOT
 * clipped at the row boundary. */
static void dec_byterun(UBYTE **src, UBYTE *dst, WORD rowbytes)
{
    while (rowbytes > 0) {
        signed char n = (signed char)*(*src)++;
        if (n >= 0) {
            WORD i;
            for (i = 0; i <= n; i++) {
                *dst++ = *(*src)++;
                rowbytes--;
            };
        } else {
            BYTE m = (BYTE)(-n);        /* 0x80 stays -128 */
            if (m >= 0) {
                WORD i;
                UBYTE v = *(*src)++;
                for (i = 0; i <= (UBYTE)m; i++) {
                    *dst++ = v;
                    rowbytes--;
                };
            };
        };
    };
}
LONG DecodePic(struct BitMap *bm REGPARM_A0, APTR iff REGPARM_A1,
               APTR a6 REGPARM_A6)
{
    struct LibData *ld = LIBD(a6);
    APTR planes[24];                /* 19.1 copies 24 ptrs */
    struct BMHD *bh;
    APTR body;
    UBYTE *src, *end;
    void (*dec)(UBYTE **, UBYTE *, WORD);
    UBYTE scratch[400];
    UBYTE mask, pi;
    WORD rows, bpr;
    ULONG rowbytes;
    int i;

    if (((ULONG *)iff)[2] != ID_ILBM)
        return seterr(ERR_NOILBM, ld);

    bh = (struct BMHD *)GetBMHD(iff, a6);
    if (!bh)                                /* error already stored */
        return 0;

    if (!bh->bmh_Depth) {                   /* empty pic → ok */
        clrerr(ld);
        return 1;
    };

    /* quirk carried over & enlarged: 24 longs are copied
     * from bm+8, reading 64 bytes past bm_Planes[8]. */
    for (i = 0; i < 24; i++)
        planes[i] = (APTR)((ULONG *)bm)[i + 2];

    body = find_chunk(iff, ID_BODY);
    if (!body)
        return seterr(ERR_NOBODY, ld);
    src = (UBYTE *)body + 8;
    end = src + ((ULONG *)body)[1];

    if (bh->bmh_Compression == 0)      dec = dec_raw;
    else if (bh->bmh_Compression == 1) dec = dec_byterun;
    else return seterr(ERR_COMPR, ld);

    mask = (bh->bmh_Masking == 1);
    rowbytes = ((bh->bmh_Width + 15) >> 3) & ~1UL;
    bpr = (WORD)bm->bm_BytesPerRow;
    rows = (WORD)bm->bm_Rows;
    if (rows > (WORD)bh->bmh_Height)        /* signed min() */
        rows = (WORD)bh->bmh_Height;

    while (src < end) {                     /* dbcc: end test  */
        if ((WORD)--rows == -1) break;      /* before each row */
        {
            APTR *pp = planes;
            pi = 0;
            while ((BYTE)pi < (BYTE)bh->bmh_Depth) {
                UBYTE *dst;
                if (pi < bm->bm_Depth) {    /* real plane */
                    dst = (UBYTE *)*pp;
                    *pp = (char *)*pp + bpr;
                    pp++;
                } else {                    /* spare → scratch */
                    dst = scratch;
                };
                dec(&src, dst, (WORD)rowbytes);
                pi = (UBYTE)(pi + 1);
            };
            if (mask)                       /* mask row → scratch */
                dec(&src, scratch, (WORD)rowbytes);
        };
    };
    clrerr(ld);
    return 1;
}
/* ---- SaveBitMap / SaveClip ------------------------------ */
/* CalcViewModes helper: HIRES w>400&&depth<=4, LACE h>=320 */
static ULONG calc_modes(struct BMHD *bh)
{
    ULONG m = 0;
    if (bh->bmh_Depth <= 4 && bh->bmh_Width > 400) m |= 0x8000;
    if (bh->bmh_Height >= 320) m |= 0x0004;
    return m;
}
/* run-length scan: match count of *p, capped 128, bounded by
 * end (reads the byte at end — quirk) */
static WORD scan_run(UBYTE *p, UBYTE *end)
{
    WORD n = 1;
    UBYTE v = *p++;
    while (*p++ == v) {
        if (n >= 128) break;
        n++;
        if (p >= end) break;
    };
    return n;
}
/* CmpByteRun1 encoder → returns compressed byte count */
static LONG enc_byterun(UBYTE *src, UBYTE *dst, WORD len)
{
    UBYTE *end = src + len;
    LONG out = 0;
    while (src < end) {
        WORD run = scan_run(src, end);
        if (run >= 3) {
            UBYTE v = *src;
            src += run;
            *dst++ = (UBYTE)(1 - run);
            *dst++ = v;
            out += 2;
        } else {
            UBYTE *lit = src;
            WORD i, n = 0;
            for (;;) {
                n++;
                if (n & 0x80) { n = 127; break; }
                if (++src >= end) break;
                if (scan_run(src, end) >= 3) break;
            };
            src = lit;
            out += n + 1;
            *dst++ = (UBYTE)(n - 1);
            for (i = 0; i < n; i++) *dst++ = *src++;
        };
    };
    return out;
}
static LONG save_raw(LONG fh, struct BitMap *bm, APTR db,
                     WORD x, WORD y, UWORD w, UWORD h)
{
    APTR pl[24];                            /* 24 planes now */
    WORD depth = bm->bm_Depth;
    LONG off = (LONG)((UWORD)y * (UWORD)bm->bm_BytesPerRow) + (UWORD)x;
    LONG total = (LONG)((UWORD)(w * (UWORD)depth)) * (UWORD)h;
    APTR *pp;
    int i;
    for (i = 0; i < 24; i++)
        pl[i] = (char *)((ULONG *)bm)[i + 2] + off;
    DBFLOOP(h - 1, {
        pp = pl;
        DBFLOOP(depth - 1, {
            if (d_Write(fh, *pp, w, db) < 0)
                return -1;
            *pp = (char *)*pp + bm->bm_BytesPerRow;
            pp++;
        });
    });
    return total;
}
static LONG save_crunch(LONG fh, struct BitMap *bm, APTR db,
                        WORD x, WORD y, UWORD w, UWORD h)
{
    APTR pl[24];
    WORD depth = bm->bm_Depth;
    LONG off = (LONG)((UWORD)y * (UWORD)bm->bm_BytesPerRow) + (UWORD)x;
    LONG total = 0;
    UBYTE cbuf[512];                        /* grew to 512 */
    APTR *pp;
    int i;
    for (i = 0; i < 24; i++)
        pl[i] = (char *)((ULONG *)bm)[i + 2] + off;
    DBFLOOP(h - 1, {
        pp = pl;
        DBFLOOP(depth - 1, {
            LONG n = enc_byterun((UBYTE *)*pp, cbuf, w);
            total += n;
            if (d_Write(fh, cbuf, n, db) < 0)
                return -1;
            *pp = (char *)*pp + bm->bm_BytesPerRow;
            pp++;
        });
    });
    return total;
}
static LONG save_worker(STRPTR name, struct BitMap *bm, UWORD *ctab,
                        ULONG flags, WORD x, WORD y, UWORD w, UWORD h,
                        APTR a6)
{
    struct LibData *ld = LIBD(a6);
    APTR db = ld->DOSBase;
    UBYTE buf[1604];
    ULONG *w32 = (ULONG *)buf;
    struct BMHD *bh = (struct BMHD *)(buf + 20);
    LONG fh = 0, bodysize, adj;

    w &= ~1;

    w32[0] = ID_FORM;
    w32[1] = 60;
    w32[2] = ID_ILBM;
    w32[3] = ID_BMHD;
    w32[4] = 20;
    bh->bmh_Width = w << 3;
    bh->bmh_Height = h;
    bh->bmh_Left = x << 3;                  /* 19.1: clip origin */
    bh->bmh_Top = y;
    bh->bmh_Depth = bm->bm_Depth;
    bh->bmh_Masking = 0;
    bh->bmh_Compression = (UBYTE)flags & 0x7f;
    bh->bmh_Pad = 0;
    bh->bmh_Transparent = 0;
    bh->bmh_XAspect = 10;
    bh->bmh_YAspect = 11;
    bh->bmh_PageWidth = w << 3;
    bh->bmh_PageHeight = h;
    w32[10] = ID_CAMG;                      /* buf+40 */
    w32[11] = 4;                            /* buf+44 */
    {
        ULONG modes = calc_modes(bh);
        if (flags & 0x80) modes |= 0x800;   /* HAM via flag bit7 */
        w32[12] = modes;                    /* buf+48 */
    };
    *(LONG *)(buf + 56) = -8;               /* no-cmap marker */

    if (ctab) {
        UBYTE *c = buf + 52;
        UBYTE depth = bm->bm_Depth;
        ULONG ncol;
        ULONG csz, i;
        if (depth == 24) depth = 8;         /* 24-bit → 256 pens */
        ncol = 1UL << depth;
        csz = (ncol * 3 + 2) & ~3UL;
        *(ULONG *)c = ID_CMAP;
        *(ULONG *)(buf + 56) = csz;         /* same slot as marker */
        c += 8;
        for (i = 0; i < ncol; i++) {
            UWORD v = ctab[i];              /* 0x0RGB → R,G,B high nibbles */
            c[0] = (UBYTE)((v >> 4) & 0xf0);
            c[1] = (UBYTE)(v & 0xf0);
            c[2] = (UBYTE)((v << 4) & 0xf0);
            c += 3;
        };
    };
    fh = d_Open(name, MODE_NEWFILE, db);
    if (!fh) goto fail;
    adj = *(LONG *)(buf + 56);              /* -8 or cmapsize */
    w32[1] += adj;
    if (d_Write(fh, buf, 68 + adj, db) < 0) goto fail;
    if (bh->bmh_Compression == 0)
        bodysize = save_raw(fh, bm, db, x, y, w, h);
    else
        bodysize = save_crunch(fh, bm, db, x, y, w, h);
    if (bodysize < 0) goto fail;
    {
        ULONG padded = ((ULONG)bodysize + 3) & ~3UL;
        *(ULONG *)(buf + 1600) = padded;
        w32[1] += padded;
        if (padded - (ULONG)bodysize) {
            ULONG z = 0;
            if (d_Write(fh, &z, padded - (ULONG)bodysize, db) < 0)
                goto fail;
        };
    };
    d_Seek(fh, 0, OFFSET_BEGINNING, db);
    adj = *(LONG *)(buf + 56);
    if (d_Write(fh, buf, 60 + adj, db) < 0) goto fail;
    *(ULONG *)(buf + 1596) = ID_BODY;
    if (d_Write(fh, buf + 1596, 8, db) < 0) goto fail;
    d_Close(fh, db);
    clrerr(ld);
    return 1;

fail:
    if (fh) d_Close(fh, db);
    return seterr(ERR_WRITE, ld);
}
LONG SaveBitMap(STRPTR name REGPARM_A0, struct BitMap *bm REGPARM_A1,
                UWORD *ctab REGPARM_A2, ULONG flags REGPARM_D0,
                APTR a6 REGPARM_A6)
{
    return save_worker(name, bm, ctab, flags, 0, 0,
                       bm->bm_BytesPerRow, bm->bm_Rows, a6);
}
LONG SaveClip(STRPTR name REGPARM_A0, struct BitMap *bm REGPARM_A1,
              UWORD *ctab REGPARM_A2, ULONG flags REGPARM_D0,
              WORD x REGPARM_D1, WORD y REGPARM_D2,
              UWORD w REGPARM_D3, UWORD h REGPARM_D4,
              APTR a6 REGPARM_A6)
{
    return save_worker(name, bm, ctab, flags, x, y, w, h, a6);
}
/* ---- GetViewModes --------------------------------------- */
LONG GetViewModes(APTR iff REGPARM_A1, APTR a6 REGPARM_A6)
{
    APTR c = find_chunk(iff, ID_CAMG);
    ULONG m;
    if (c) return ((ULONG *)c)[2] & 0xffff9efdUL;  /* 19.1 mask */
    c = GetBMHD(iff, a6);
    if (!c) return 0;
    m = calc_modes((struct BMHD *)c);
    if (((struct BMHD *)c)->bmh_Depth >= 6) m |= 0x800;
    return m;
}
/* ---- IFFError ------------------------------------------- */
LONG IFFError(APTR a6 REGPARM_A6)
{
    struct OpenNode *n = findnode(LIBD(a6));
    LONG e;
    if (!n) return -1;
    e = n->error;
    n->error = 0;
    return e;
}
/* ---- DecodeAnim ----------------------------------------- */
/* ANIM operation-5 delta decode.  src = this plane's DLTA
 * stream, column-major: for each of BytesPerRow byte-columns a
 * count byte followed by that many ops.  op > 0 skips op rows
 * (via the caller's row-offset table), op < 0 copies |op|
 * literal bytes straight down the column, op == 0 reads a
 * count+value pair and replicates count bytes down the column.
 * (The original used Duff-unrolled store loops — behaviour is
 * identical.) */
static void anim5_dec(UBYTE *src, UBYTE *dst, WORD bpr, WORD *tab)
{
    UBYTE *p;
    UBYTE v;
    WORD i, ops, cnt;
    BYTE n;
    DBFPRE(bpr, {
        p = dst;
        ops = *src++;
        DBFPRE(ops, {
            n = (BYTE)*src++;
            if (n < 0) {
                cnt = n & 0x7f;
                for (i = 0; i < cnt; i++) {
                    *p = *src++;
                    p += bpr;
                }
            } else if (n == 0) {
                cnt = *src++;
                v = *src++;
                for (i = 0; i < cnt; i++) {
                    *p = v;
                    p += bpr;
                }
            } else {
                p += tab[n];                /* skip n rows */
            }
        });
        dst++;
    });
}
LONG DecodeAnim(struct BitMap *bm REGPARM_A0, APTR iff REGPARM_A1,
                APTR a6 REGPARM_A6)
{
    struct LibData *ld = LIBD(a6);
    WORD bpr = (WORD)bm->bm_BytesPerRow;
    WORD rows = (WORD)bm->bm_Rows;
    WORD depth = (WORD)bm->bm_Depth;
    APTR anhd, dlta;
    WORD tab[rows];                         /* row-offset table */
    UBYTE *d;
    WORD i;

    {   /* tab[i] = i * bpr */
        WORD off = 0, n = rows;
        WORD *t = tab;
        while ((WORD)--n != -1) { *t++ = off; off += bpr; }
    }
    if (((ULONG *)iff)[2] != ID_ILBM)
        return seterr(ERR_NOILBM, ld);
    anhd = find_chunk(iff, ID_ANHD);
    if (!anhd) return seterr(ERR_NOANHD, ld);
    if (((UBYTE *)anhd)[8] != 5)            /* anhd operation */
        return seterr(ERR_COMPR, ld);
    dlta = find_chunk(iff, ID_DLTA);
    if (!dlta) return seterr(ERR_NODLTA, ld);
    d = (UBYTE *)dlta + 8;
    {
        ULONG *lp = (ULONG *)d;
        APTR *pp = bm->bm_Planes;
        for (i = 0; i < depth; i++) {
            ULONG off = lp[i];
            if (off)
                anim5_dec(d + off, (UBYTE *)pp[i], bpr, tab);
        }
    }
    return clrerr(ld);
}
