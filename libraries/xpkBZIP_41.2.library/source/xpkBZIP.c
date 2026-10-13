/* xpkBZIP.library 41.2 — XPK sublibrary reconstruction
 *
 * Thin m68k front-end: all codec work is delegated to the
 * PowerPC object LIBS:ppc/xpkBZIP.elf, loaded and run via
 * ppc.library (PowerUP):
 *   -30  load object      (a0=path)            -> d0 obj
 *   -36  unload object    (a0=obj)
 *   -42  run function     (a0=obj, a1=frame)   -> d0 result
 *   -60  alloc work mem   (d0=size, d1=1)      -> d0 ptr
 *   -66  free work mem    (a1=ptr)
 *
 * XpkSubParams (a0, longwords):
 *   [0]=src  [1]=inlen  [2]=dst  [3]=outbufsize  [4]=outlen result
 *   [7]=level (0-100, pack only)  [13..15]=work bufs  [16]=elf obj
 */
typedef unsigned char  UBYTE;
typedef unsigned long  ULONG;
typedef long           LONG;
typedef void          *APTR;

extern char  datapc[];
extern const char elfpath[];

#define PPCBASE (*(APTR *)(datapc + 124))

static APTR ppc_load(const char *path)
{
    register APTR r asm("d0");
    register APTR pp asm("a6") = PPCBASE;
    __asm__ volatile("moveal %1,%%a0\n\tjsr %%a6@(-30)"
                     : "=r"(r) : "g"(path), "r"(pp)
                     : "d1","a0","a1","memory");
    return r;
}

static void ppc_unload(APTR obj)
{
    register APTR pp asm("a6") = PPCBASE;
    __asm__ volatile("moveal %0,%%a0\n\tjsr %%a6@(-36)"
                     :: "g"(obj), "r"(pp)
                     : "d0","d1","a0","a1","memory");
}

static LONG ppc_run(APTR obj, ULONG *frame)
{
    register LONG r asm("d0");
    register APTR pp asm("a6") = PPCBASE;
    __asm__ volatile("moveal %1,%%a0\n\tmoveal %2,%%a1\n\tjsr %%a6@(-42)"
                     : "=r"(r) : "g"(obj), "g"(frame), "r"(pp)
                     : "d1","a0","a1","memory");
    return r;
}

static APTR ppc_alloc(ULONG size)
{
    register APTR r asm("d0");
    register APTR pp asm("a6") = PPCBASE;
    __asm__ volatile("movel %1,%%d0\n\tmoveq #1,%%d1\n\tjsr %%a6@(-60)"
                     : "=r"(r) : "g"(size), "r"(pp)
                     : "d1","a0","a1","memory");
    return r;
}

static void ppc_free(APTR p)
{
    register APTR pp asm("a6") = PPCBASE;
    __asm__ volatile("moveal %0,%%a1\n\tjsr %%a6@(-66)"
                     :: "g"(p), "r"(pp)
                     : "d0","d1","a0","a1","memory");
}

/* shared free of the three work buffers (a[13..15], freed in
 * reverse order) — doubles as the -42 PackFree vector.  The
 * original returns whatever the last FreeVec left in d0. */
static void free_bufs(ULONG *a)
{
    if (a[15]) { ppc_free((APTR)a[15]); a[15] = 0; }
    if (a[14]) { ppc_free((APTR)a[14]); a[14] = 0; }
    if (a[13]) { ppc_free((APTR)a[13]); a[13] = 0; }
}

/* -42 PackFree — identical to free_bufs; d0 is unspecified. */
void XpksPackFree(register ULONG *a asm("a0"))
{
    free_bufs(a);
}

/* -60 UnpackFree — same frees but explicitly returns 0. */
LONG XpksUnpackFree(register ULONG *a asm("a0"))
{
    free_bufs(a);
    return 0;
}

/* -36 XpksPackChunk — pack via PPC function index 1.
 *
 * mode = (9+level)/10, min 1 — level 1..10->1 ... 91..100->10.
 * QUIRK: out[0] is written with the mode byte BEFORE the
 * 1..10 range check, so an invalid level still clobbers it.
 * QUIRK: the work buffers are only (re)allocated when ALL
 * three are zero — a partially-freed set is used as-is.
 */
LONG XpksPackChunk(register ULONG *a asm("a0"))
{
    ULONG mode;
    __asm__("movel %1,%%d0; moveq #9,%%d1; addl %%d1,%%d0;\n\t"
            "moveq #10,%%d1; divul.l %%d1,%%d0:%%d0; movel %%d0,%0"
            : "=g"(mode) : "g"(a[7]) : "d0","d1");
    ULONG blk, fr[11];

    if (!mode) mode = 1;
    ((UBYTE *)a[2])[0] = (UBYTE)mode;          /* before range check */
    blk = mode * 102400;
    if (mode < 1 || mode > 10) return -12;     /* mode<1 is dead */
    a[16] = (ULONG)ppc_load(elfpath);
    if (!a[16]) return -33;
    if (!a[13] && !a[14] && !a[15]) {
        a[13] = (ULONG)ppc_alloc(blk * 4);
        a[14] = (ULONG)ppc_alloc(blk * 4);
        a[15] = (ULONG)ppc_alloc(0x40004);
    }
    if (!a[13] || !a[14] || !a[15]) {
        free_bufs(a);
        return -7;
    }
    fr[0] = 1;            /* PPC func: compress */
    fr[1] = mode;
    fr[2] = a[0];         /* src */
    fr[3] = a[2] + 1;     /* dst + 1 (mode byte at 0) */
    fr[4] = a[1];         /* inlen */
    fr[5] = a[3];         /* outbufsize */
    fr[6] = a[13];
    fr[7] = a[14];
    fr[8] = a[15];
    fr[9] = 0;
    fr[10] = 0;
    a[4] = ppc_run((APTR)a[16], fr);           /* outlen result */
    if (a[16]) { ppc_unload((APTR)a[16]); a[16] = 0; }
    return 0;
}

/* -54 XpksUnpackChunk — unpack via PPC function index 0.
 * mode is read back from src[0] (pack wrote it); in+1 is fed
 * to the PPC side.  Return: -1 from PPC -> -17, -2 -> -5,
 * produced != outbufsize -> -4, else 0.
 */
LONG XpksUnpackChunk(register ULONG *a asm("a0"))
{
    ULONG mode = ((UBYTE *)a[0])[0];
    ULONG blk = mode * 102400;
    LONG r;
    ULONG fr[11];

    if (mode < 1 || mode > 10) return -12;
    a[16] = (ULONG)ppc_load(elfpath);
    if (!a[16]) return -33;
    if (!a[13] && !a[14] && !a[15]) {
        a[13] = (ULONG)ppc_alloc(blk * 4);
        a[14] = (ULONG)ppc_alloc(blk);
        a[15] = (ULONG)ppc_alloc(blk);
    }
    if (!a[13] || !a[14] || !a[15]) {
        free_bufs(a);
        return -7;
    }
    fr[0] = 0;            /* PPC func: decompress */
    fr[1] = mode;
    fr[2] = a[0] + 1;     /* src + 1 (skip mode byte) */
    fr[3] = a[2];         /* dst */
    fr[4] = a[1];         /* inlen */
    fr[5] = a[3];         /* outbufsize */
    fr[6] = a[13];
    fr[7] = 0;
    fr[8] = 0;
    fr[9] = a[14];
    fr[10] = a[15];
    r = ppc_run((APTR)a[16], fr);
    if (a[16]) { ppc_unload((APTR)a[16]); a[16] = 0; }
    if (r == -1) return -17;
    if (r == -2) return -5;
    return r == (LONG)a[3] ? 0 : -4;
}
