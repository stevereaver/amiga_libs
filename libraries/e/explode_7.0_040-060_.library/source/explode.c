/*
 * explode.library 7.0 (28.08.96) — Struijk/Brouwer, 68040/60 bugfix by
 * Grzegorz Calkowski.
 *
 * Reconstructed from the 1784-byte binary.  LibInit patches BOTH the
 * dos.library LoadSeg vector (-150) and the NewLoadSeg vector (-768)
 * with 6/8-byte 'jsr old' stubs living in the library's own code hunk;
 * after each successful load the shared checker inspects hunk0 for the
 * packed-program signature and inflates the segment in place (stubs,
 * signature check and the LZ/Huffman decoder are verbatim asm in
 * explode_lib.s).
 *
 * Vectors: -6 Open, -12 Close, -18/-24 return-0 stub (the real expunge
 * only runs from Close once bit3 of the private flag byte is set),
 * -30 Explode (asm trampoline; returns INTO the inflated segment),
 * -36 mark-for-expunge.
 *
 * Notable shipped behaviours reproduced here:
 *   - OpenLibrary("dos.library",37) failure skips the patch but still
 *     returns the library base (init "succeeds" with no wedge).
 *   - Expunge restores both vectors blindly — it never checks that the
 *     slot still holds our stub before calling SetFunction.
 *   - CacheClearU is invoked unconditionally (the 040/060 fix); safe
 *     only because dos V37 implies exec V37.
 *   - Datatab declares lib_Version 6 / rev 0 although the idstring and
 *     rt_Version both say 7.0.
 */

typedef unsigned char  UBYTE;
typedef short          WORD;
typedef unsigned short UWORD;
typedef long           LONG;
typedef unsigned long  ULONG;
typedef char          *STRPTR;
typedef void          *APTR;

struct ExpBase {
    APTR   ln_Succ;         /*  0 */
    APTR   ln_Pred;         /*  4 */
    UBYTE  ln_Type;         /*  8 */
    UBYTE  ln_Pri;          /*  9 */
    STRPTR ln_Name;         /* 10 */
    UBYTE  lib_Flags;       /* 14 */
    UBYTE  lib_pad;         /* 15 */
    UWORD  lib_NegSize;     /* 16 */
    UWORD  lib_PosSize;     /* 18 */
    UWORD  lib_Version;     /* 20 */
    UWORD  lib_Revision;    /* 22 */
    STRPTR lib_IdString;    /* 24 */
    ULONG  lib_Sum;         /* 28 */
    UWORD  lib_OpenCnt;     /* 32 */
    UBYTE  eb_Flags;        /* 34 bit3 = expunge on last close */
    UBYTE  eb_pad;          /* 35 */
    APTR   eb_DosBase;      /* 36 */
    APTR   eb_SegList;      /* 40 */
    UWORD  eb_pad2;         /* 44 unused */
    APTR   eb_SavedLoad;    /* 46 old LoadSeg vector   */
    APTR   eb_SavedNewLoad; /* 50 old NewLoadSeg vector */
};

extern char exp_dosname[];         /* "dos.library" in lib.s */
/* The two installable stubs: 'jsr abs.l' with a LibInit-patched target. */
extern struct { UWORD op; APTR addr; } ExpStubNL;   /* -768 NewLoadSeg */
extern struct { UWORD op; APTR addr; } ExpStub;     /* -150 LoadSeg    */

/* ---- exec calls ----------------------------------------------------- */
static void ex_forbid(APTR ex)
{ register APTR __e __asm("a6") = ex;
  __asm volatile("jsr a6@(-132)\n" ::"r"(__e):"d0","d1","a0","a1","cc","memory"); }
static void ex_permit(APTR ex)
{ register APTR __e __asm("a6") = ex;
  __asm volatile("jsr a6@(-138)\n" ::"r"(__e):"d0","d1","a0","a1","cc","memory"); }
static void ex_freemem(APTR ex, APTR mem, ULONG sz)
{ register APTR __m __asm("a1") = mem; register ULONG __s __asm("d0") = sz;
  register APTR __e __asm("a6") = ex;
  __asm volatile("jsr a6@(-210)\n" ::"r"(__e),"r"(__m),"r"(__s):"d1","a0","cc","memory"); }
static void ex_remove(APTR ex, APTR node)
{ register APTR __n __asm("a1") = node; register APTR __e __asm("a6") = ex;
  __asm volatile("jsr a6@(-252)\n" ::"r"(__e),"r"(__n):"d0","d1","a0","cc","memory"); }
static void ex_closelib(APTR ex, APTR lib)
{ register APTR __l __asm("a1") = lib; register APTR __e __asm("a6") = ex;
  __asm volatile("jsr a6@(-414)\n" ::"r"(__e),"r"(__l):"d0","d1","a0","cc","memory"); }
static APTR ex_setfunc(APTR ex, APTR lib, LONG off, APTR fn)
{ register APTR __l __asm("a1") = lib; register LONG __o __asm("a0") = off;
  register APTR __f __asm("d0") = fn; register APTR __e __asm("a6") = ex;
  __asm volatile("jsr a6@(-420)\n" : "+r"(__f) :"r"(__e),"r"(__l),"r"(__o):"d1","cc","memory");
  return __f; }
static APTR ex_oldopenlib(APTR ex, STRPTR name, ULONG ver)
{ register STRPTR __n __asm("a1") = name; register ULONG __v __asm("d0") = ver;
  register APTR __e __asm("a6") = ex;
  __asm volatile("jsr a6@(-552)\n" : "+r"(__v) :"r"(__e),"r"(__n):"d1","a0","cc","memory");
  return (APTR)__v; }
static void ex_cacheclearu(APTR ex)
{ register APTR __e __asm("a6") = ex;
  __asm volatile("jsr a6@(-636)\n" ::"r"(__e):"d0","d1","a0","a1","cc","memory"); }

/* ---- shared expunge body (only reached via Close) -------------------- */
static APTR expunge_body(register struct ExpBase *b)
{
    APTR ex = *(APTR *)4;
    APTR seg;
    ex_forbid(ex);
    ex_setfunc(ex, b->eb_DosBase, -150, b->eb_SavedLoad);
    ex_setfunc(ex, b->eb_DosBase, -768, b->eb_SavedNewLoad);
    ex_cacheclearu(ex);
    ex_permit(ex);
    seg = b->eb_SegList;
    ex_remove(ex, b);
    ex_closelib(ex, b->eb_DosBase);
    ex_freemem(ex, (UBYTE *)b - b->lib_NegSize,
               (ULONG)b->lib_NegSize + b->lib_PosSize);
    return seg;
}

/* ---- LibInit: install the LoadSeg/NewLoadSeg wedges ------------------- */
struct ExpBase *LibInit(register struct ExpBase *b __asm("d0"),
                         register APTR seg __asm("a0"),
                         register APTR ex __asm("a6"))
{
    APTR old;

    b->eb_SegList = seg;
    b->eb_DosBase = ex_oldopenlib(ex, exp_dosname, 37);
    if (!b->eb_DosBase)
        return b;                /* shipped defect: still "succeeds" */
    ex_forbid(ex);
    old = ex_setfunc(ex, b->eb_DosBase, -150, &ExpStub);
    ExpStub.addr = old;
    b->eb_SavedLoad = old;
    old = ex_setfunc(ex, b->eb_DosBase, -768, &ExpStubNL);
    ExpStubNL.addr = old;
    b->eb_SavedNewLoad = old;
    ex_cacheclearu(ex);
    ex_permit(ex);
    return b;
}

/* ---- -6: Open -------------------------------------------------------- */
APTR LibOpen(register struct ExpBase *b __asm("a6"))
{
    b->lib_OpenCnt++;
    b->eb_Flags &= ~8;
    return b;
}

/* ---- -12: Close ------------------------------------------------------- */
APTR LibClose(register struct ExpBase *b __asm("a6"))
{
    if (--b->lib_OpenCnt)
        return 0;
    if (!(b->eb_Flags & 8))
        return 0;
    return expunge_body(b);
}

/* ---- -36: request expunge -------------------------------------------- */
void ExpMark(register struct ExpBase *b __asm("a6"))
{
    b->eb_Flags |= 8;
}
