/* iff.library 16.4 reconstruction
 *
 * "IFF 16.4 (16-May-1989) by Christian A. Weber" — the classic
 * third-party IFF file library.  Loads entire IFF FORMs into
 * memory, walks chunks, decodes ILBM BODY (raw / CmpByteRun1)
 * into BitMaps, and saves BitMaps as ILBM with an optional
 * ByteRun1 crunch pass.  Errors are tracked per-task through
 * a node list hanging off the library data area (IFFError()).
 *
 * Shipped quirks reproduced faithfully — see okf/findings:
 *  - LibOpen fails if the calling task already holds a node
 *    ("not a bug, it's a feature" per the original docs).
 *  - DecodePic requires bmhd.nPlanes <= bm_Depth.
 *  - Raw decoder entry lands mid-loop on the dbf: copies
 *    exactly rowbytes bytes (not rowbytes+1).
 *  - ByteRun1 decoder treats 0x80 as 129-byte replicate
 *    instead of a NOP; runs are NOT clipped at rowbytes.
 *  - OpenIFF ignores the 12-byte header Read() result and any
 *    short read of the FORM body; a failed body Read() leaks
 *    the allocated node.
 *  - FindChunk walks chunks up to chunkstart+formsize — 4
 *    bytes past the real chunk end (subtype is counted).
 *  - SaveClip writes x offsets and widths in BYTES, not
 *    pixels (BMHD width = wbytes*8).
 *  - SaveBitMap/SaveClip patch the FORM size + BODY header by
 *    rewinding after streaming the BODY data.
 *  - The flags byte's bit 7 doubles as a HAM marker: it is
 *    stripped from the stored compression byte and sets the
 *    CAMG HAM bit instead.
 *  - GetViewModes derives HAM from nPlanes>=6 (halfbrite
 *    pictures misdetect, per the original docs).
 */

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef unsigned long  ULONG;
typedef short          WORD;
typedef long           LONG;
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
    APTR   seglist;                 /* +34 */
    UBYTE  delexp;                  /* +38: bit 3 = delayed expunge */
    UBYTE  pad39[1];
    APTR   DOSBase;                 /* +40 */
    ULONG  list[3];                 /* +44: MinList (head/tail/tailpred) */
};

struct OpenNode {                   /* per-task handle, 22 bytes */
    APTR   next, prev;              /* +0,+4 MinNode links */
    UBYTE  pad[6];                  /* +6..+13 */
    APTR   task;                    /* +14 FindTask(NULL) owner */
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
#define ERR_PLANES      27
#define ERR_COMPR       28

#define SYSB (*(volatile APTR *)4)

/* ---- exec imports (a6 = SysBase) ------------------------ */
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
static inline APTR x_FindTask(APTR name, APTR sb) {
    register APTR r __asm("d0"); register APTR a1 __asm("a1") = name;
    register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-294)" : "=r"(r) : "r"(a1),"r"(a6)
                   : "a0","memory","cc");
    return r;
}
static inline void x_AddTail(APTR list, APTR node, APTR sb) {
    register APTR a0 __asm("a0") = list; register APTR a1 __asm("a1") = node;
    register APTR a6 __asm("a6") = sb;
    __asm volatile("jsr a6@(-246)" :: "r"(a0),"r"(a1),"r"(a6)
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

/* nostdlib support routines */
LONG __mulsi3(LONG a, LONG b)
{
    LONG r = 0;
    while (b) { if (b & 1) r += a; a <<= 1; b >>= 1; }
    return r;
}
/* ---- per-task error node list --------------------------- */
static struct OpenNode *findnode(struct LibData *ld, APTR sb)
{
    APTR task = x_FindTask(0, sb);
    struct OpenNode *n;
    for (n = (struct OpenNode *)ld->list[0]; n->next;
         n = (struct OpenNode *)n->next)
        if (n->task == task) return n;
    return 0;
}
static LONG clrerr(struct LibData *ld, APTR sb)
{
    struct OpenNode *n = findnode(ld, sb);
    if (n) n->error = 0;
    return 1;
}
static LONG seterr(LONG code, struct LibData *ld, APTR sb)
{
    struct OpenNode *n = findnode(ld, sb);
    if (n) n->error = code;
    return 0;
}
/* ---- OpenIFF / NewOpenIFF ------------------------------- */
static APTR open_worker(STRPTR name, LONG memattr, APTR a6)
{
    struct LibData *ld = LIBD(a6);
    APTR sb = SYSB, db = ld->DOSBase;
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
                    r = d_Read(fh, (char *)node + 16, hdr[1], db);
                    if (r < 0) {
                        d5 = ERR_READ;      /* node leaked */
                    } else {
                        ULONG *p = (ULONG *)((char *)node + 4);
                        p[0] = hdr[0]; p[1] = hdr[1]; p[2] = hdr[2];
                    };
                };
            };
        };
        d_Close(fh, db);
    };
    if (d5) {
        seterr(d5, ld, sb);
        return 0;
    };
    clrerr(ld, sb);
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
        x_FreeMem(base, base[0], SYSB);
    };
    return clrerr(LIBD(a6), SYSB);
}
/* ---- FindChunk ------------------------------------------ */
static APTR find_chunk(APTR iff, ULONG id)
{
    ULONG size = ((ULONG *)iff)[1];         /* FORM size */
    UBYTE *p = (UBYTE *)iff + 12;
    UBYTE *end = p + size;
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
    if (!c) return (APTR)seterr(ERR_NOBMHD, LIBD(a6), SYSB);
    clrerr(LIBD(a6), SYSB);
    return (APTR)((UBYTE *)c + 8);
}
/* ---- GetColorTab ---------------------------------------- */
LONG GetColorTab(APTR iff REGPARM_A1, UWORD *tab REGPARM_A0,
                 APTR a6 REGPARM_A6)
{
    APTR c = find_chunk(iff, ID_CMAP);
    UBYTE *s;
    WORD n, i;
    if (!c) return 0;                       /* no error stored */
    s = (UBYTE *)c + 8;
    n = (WORD)(((WORD)((ULONG *)c)[1]) / 3); /* divs.w #3 */
    DBFLOOP(n - 1, {
        UWORD r = s[0];
        UWORD g = s[1];
        UWORD b = s[2];
        *tab++ = (UWORD)((r << 4) | g | (b >> 4));
        s += 3;
    });
    return n;
}
/* ---- DecodePic ------------------------------------------ */
/* vanilla copy: decoder entry lands ON the dbf at 0x44e — the
 * count decrements before the first copy, so exactly rowbytes
 * bytes are copied (not rowbytes+1 as a naive reading gives). */
static void dec_raw(UBYTE **src, UBYTE *dst, WORD rowbytes)
{
    DBFLOOP((WORD)(rowbytes - 1), *dst++ = *(*src)++);
}
/* CmpByteRun1: literal n+1 / replicate -n+1; 0x80 → 129 reps
 * (no NOP case); runs are NOT clipped at the row boundary. */
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
            UWORD i;
            UBYTE v = *(*src)++;
            UWORD cnt = (UBYTE)(-n);        /* 0x80 → 128 */
            for (i = 0; i <= cnt; i++) {    /* cnt+1 reps */
                *dst++ = v;
                rowbytes--;
            };
        };
    };
}
LONG DecodePic(struct BitMap *bm REGPARM_A0, APTR iff REGPARM_A1,
               APTR a6 REGPARM_A6)
{
    struct LibData *ld = LIBD(a6);
    APTR planes[8];
    struct BMHD *bh;
    APTR body;
    UBYTE *src, *end;
    void (*dec)(UBYTE **, UBYTE *, WORD);
    WORD nplanes, rows, plane, row, mask;
    UWORD rowbytes;
    int i;

    if (((ULONG *)iff)[2] != ID_ILBM)
        return seterr(ERR_NOILBM, ld, SYSB);

    bh = (struct BMHD *)GetBMHD(iff, a6);
    if (!bh)                                /* error already stored */
        return 0;

    for (i = 0; i < 8; i++) planes[i] = bm->bm_Planes[i];

    nplanes = bh->bmh_Depth;
    if (nplanes > bm->bm_Depth)             /* blss: needs <= */
        return seterr(ERR_PLANES, ld, SYSB);

    body = find_chunk(iff, ID_BODY);
    if (!body)
        return seterr(ERR_NOBODY, ld, SYSB);
    src = (UBYTE *)body + 8;
    end = src + ((ULONG *)body)[1];

    if (bh->bmh_Compression == 0)      dec = dec_raw;
    else if (bh->bmh_Compression == 1) dec = dec_byterun;
    else return seterr(ERR_COMPR, ld, SYSB);

    mask = (bh->bmh_Masking == 1);
    rowbytes = ((bh->bmh_Width + 15) >> 3) & ~1;
    rows = bm->bm_Rows - 1;

    {
        APTR *pp;
        DBFLOOP(rows, {
            pp = planes;
            DBFLOOP(nplanes - 1, {
                dec(&src, (UBYTE *)*pp, (WORD)rowbytes);
                *pp = (char *)*pp + bm->bm_BytesPerRow;
                pp++;
            });
            if (mask) {                     /* mask row → scratch */
                UBYTE scratch[260];
                dec(&src, scratch, (WORD)rowbytes);
            };
            if (src >= end) break;
        });
    };
    clrerr(ld, SYSB);
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
    APTR pl[8];
    WORD depth = bm->bm_Depth;
    LONG off = (LONG)((UWORD)y * (UWORD)bm->bm_BytesPerRow) + (UWORD)x;
    LONG total = (LONG)((UWORD)(w * (UWORD)depth)) * (UWORD)h;
    APTR *pp;
    int i;
    for (i = 0; i < 8; i++)
        pl[i] = (char *)bm->bm_Planes[i] + off;
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
    APTR pl[8];
    WORD depth = bm->bm_Depth;
    LONG off = (LONG)((UWORD)y * (UWORD)bm->bm_BytesPerRow) + (UWORD)x;
    LONG total = 0;
    UBYTE cbuf[260];
    APTR *pp;
    int i;
    for (i = 0; i < 8; i++)
        pl[i] = (char *)bm->bm_Planes[i] + off;
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
    APTR sb = SYSB, db = ld->DOSBase;
    UBYTE buf[268];
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
    bh->bmh_Left = 0;
    bh->bmh_Top = 0;
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
        ULONG ncol = 1UL << bm->bm_Depth;
        ULONG csz = (ncol * 3 + 2) & ~3UL;
        ULONG i;
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
        *(ULONG *)(buf + 256) = padded;
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
    *(ULONG *)(buf + 252) = ID_BODY;
    if (d_Write(fh, buf + 252, 8, db) < 0) goto fail;
    d_Close(fh, db);
    clrerr(ld, sb);
    return 1;

fail:
    if (fh) d_Close(fh, db);
    return seterr(ERR_WRITE, ld, sb);
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
    if (c) return ((ULONG *)c)[2];
    c = GetBMHD(iff, a6);
    if (!c) return 0;
    m = calc_modes((struct BMHD *)c);
    if (((struct BMHD *)c)->bmh_Depth >= 6) m |= 0x800;
    return m;
}
/* ---- IFFError ------------------------------------------- */
LONG IFFError(APTR a6 REGPARM_A6)
{
    struct OpenNode *n = findnode(LIBD(a6), SYSB);
    LONG e;
    if (!n) return -1;
    e = n->error;
    n->error = 0;
    return e;
}