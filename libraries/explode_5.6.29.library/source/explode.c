/*
 * explode.library "Executable Explode Wedge V5.6.29" (16-Jul-91)
 *
 * Reconstructed from the 1644-byte binary.  LibInit patches the
 * dos.library LoadSeg vector (-150) with an 8-byte stub living in the
 * library's own code hunk; every successful LoadSeg then checks hunk0
 * for the packed-program signature and inflates the segment in place
 * (decoder + wedge stub are verbatim asm in explode_lib.s).
 *
 * Vectors: -6 Open, -12 Close, -18 return-0 stub (the real expunge
 * only runs from Close once bit3 of the private flag byte is set),
 * -24 same stub, -30 Explode (asm trampoline), -36 mark-for-expunge.
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
    UWORD  eb_SavedW;       /* 44 saved slot opcode word */
    ULONG  eb_SavedL;       /* 46 saved slot operand     */
};

extern char exp_dosname[];         /* "dos.library" in lib.s */
extern ULONG ExpStub[];            /* the installable stub   */

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
/* Alert takes its code in D7; 0x8003xxxx deadends and never returns. */
static void ex_alert(APTR ex, ULONG code)
{ register ULONG __c __asm("d7") = code; register APTR __e __asm("a6") = ex;
  __asm volatile("jsr a6@(-108)\n" ::"r"(__e),"r"(__c):"d0","d1","a0","a1","cc","memory"); }

/* ---- shared expunge body (only reached via Close) ------------------- */
static APTR expunge_body(register struct ExpBase *b)
{
    APTR ex = *(APTR *)4;
    UBYTE *slot = (UBYTE *)b->eb_DosBase - 150;
    APTR seg = 0;
    /* only unpatch if the slot is still our 'jmp abs -> stub' */
    if (*(UWORD *)slot == 0x4ef9 &&
        (*(ULONG *)(slot + 2) == (ULONG)ExpStub ||
         *(ULONG *)(slot + 2) == (ULONG)ExpStub + 2)) {
        seg = b->eb_SegList;
        ex_remove(ex, b);
        *(UWORD *)slot = b->eb_SavedW;
        *(ULONG *)(slot + 2) = b->eb_SavedL;
        ex_closelib(ex, b->eb_DosBase);
        ex_freemem(ex, (UBYTE *)b - b->lib_NegSize,
                   (ULONG)b->lib_NegSize + b->lib_PosSize);
    }
    return seg;
}

/* ---- LibInit: install the LoadSeg wedge ----------------------------- */
struct ExpBase *LibInit(register struct ExpBase *b __asm("d0"),
                         register APTR seg __asm("a0"),
                         register APTR ex __asm("a6"))
{
    UBYTE *slot;
    LONG delta;

    b->eb_SegList = seg;
    b->eb_DosBase = ex_oldopenlib(ex, exp_dosname, 33);
    if (!b->eb_DosBase)
        ex_alert(ex, 0x80038007);   /* AT_DEADEND|AG_OpenLib|AO_DOSLib */
    ex_forbid(ex);
    slot = (UBYTE *)b->eb_DosBase - 150;    /* LoadSeg vector slot */
    b->eb_SavedW = *(UWORD *)slot;
    b->eb_SavedL = *(ULONG *)(slot + 2);
    if (*(UWORD *)slot == 0x4ef9) {         /* normal 'jmp abs' vector */
        ExpStub[1] = *(ULONG *)(slot + 2);  /* old target -> jsr op    */
        delta = 2;                          /* install stub+2 (jsr part) */
    } else if (slot[0] == 0x70 &&           /* 'moveq #n,d0 ; bra.w'   */
               *(UWORD *)(slot + 2) == 0x6000) { /* foreign wedge */
        ((UBYTE *)ExpStub)[1] = slot[1];    /* keep its moveq argument */
        ExpStub[1] = (ULONG)(slot + 4 + *(WORD *)(slot + 4));
        delta = 0;                          /* install full stub       */
    } else {
        ex_alert(ex, 0x00028007);           /* unpatchable slot: give up */
        goto out;
    }
    ex_setfunc(ex, b->eb_DosBase, -150, (UBYTE *)ExpStub + delta);
    if (*(UWORD *)((UBYTE *)ex + 20) >= 37) /* exec lib_Version >= 37  */
        ex_cacheclearu(ex);
out:
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

/* ---- -12: Close ------------------------------------------------------ */
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
