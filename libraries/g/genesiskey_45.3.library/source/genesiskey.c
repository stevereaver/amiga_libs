/*
 * genesiskey.library 45.3 (28.11.2000)
 *
 * Reconstructed from the 1908-byte three-hunk binary.
 *
 * This is a generated registration/key library for the Genesis TCP/IP
 * stack: it carries no resident-init of its own (rt_Init = data-hunk
 * offset of a MakeLibrary InitTable; a custom loader builds the lib),
 * holds the installed serial string + OS string in its data hunk, and
 * exposes them as hunk offsets through two vectors.  Init requires an
 * 68020+ (AttnFlags & AFF_68020) or the library frees itself.
 *
 * Vectors (absolute functab):
 *   -6  open, -12 close, -18 expunge, -24 return-0
 *   -30..-48 empty stubs, -54 socket probe, -60 stub
 *   -66 returns 0x20 (serial offset), -72 stub
 *   -78 returns 0x120 (OS-string offset), -84/-90 empty stubs (crossed)
 */

typedef unsigned char  UBYTE;
typedef short          WORD;
typedef unsigned short UWORD;
typedef long           LONG;
typedef unsigned long  ULONG;
typedef char          *STRPTR;
typedef void          *APTR;

struct GKLib {
    APTR   ln_Succ;         /*  0 */
    APTR   ln_Pred;         /*  4 */
    UBYTE  ln_Type;         /*  8 */
    UBYTE  ln_Pri;          /*  9 */
    STRPTR ln_Name;         /* 10 */
    UBYTE  lib_Flags;       /* 14 (bit3 = delayed expunge) */
    UBYTE  lib_pad;         /* 15 */
    UWORD  lib_NegSize;     /* 16 */
    UWORD  lib_PosSize;     /* 18 */
    UWORD  lib_Version;     /* 20 (stays 0 - no data table)   */
    UWORD  lib_Revision;    /* 22 (init writes 3)             */
    STRPTR lib_IdString;    /* 24 */
    ULONG  lib_Sum;         /* 28 */
    UWORD  lib_OpenCnt;     /* 32 */
    UWORD  gk_pad;          /* 34 */
    UBYTE  gk_sem[46];      /* 36 SignalSemaphore             */
};                          /* = 0x52 = InitTable dataSize    */

/* AttnFlags lives at offset 296 in ExecBase; bit1 = AFF_68020.        */
struct GKExec {
    UBYTE  pad[296];
    UWORD  AttnFlags;
};

extern APTR   gk_exec;          /* data-hunk runtime slots            */
extern APTR   gk_dos;
extern APTR   gk_intu;
extern APTR   gk_util;
extern ULONG  gk_seglist;       /* bss hunk                           */
extern char   gk_dosname[];     /* code-resident strings              */
extern char   gk_intuname[];
extern char   gk_utilname[];
extern char   gk_genesisname[];
extern char   gk_sockname[];

/* ---- exec calls (base comes from the data-hunk slot / init arg) ----- */
static APTR ex_openlib(struct GKExec *ex, STRPTR name, ULONG ver)
{ register struct GKExec *__e __asm("a6") = ex;
  register STRPTR __n __asm("a1") = name; register ULONG __v __asm("d0") = ver;
  __asm volatile("jsr a6@(-552)\n"
      : "+r"(__e),"+r"(__n),"+r"(__v) : : "d1","a0","cc","memory");
  return (APTR)__v; }
static void ex_closelib(struct GKExec *ex, APTR lib)
{ register struct GKExec *__e __asm("a6") = ex;
  register APTR __l __asm("a1") = lib;
  __asm volatile("jsr a6@(-414)\n" ::"r"(__e),"r"(__l):"d0","d1","a0","cc","memory"); }
static void ex_freemem(struct GKExec *ex, APTR mem, ULONG sz)
{ register struct GKExec *__e __asm("a6") = ex;
  register APTR __m __asm("a1") = mem; register ULONG __s __asm("d0") = sz;
  __asm volatile("jsr a6@(-210)\n" ::"r"(__e),"r"(__m),"r"(__s):"d1","a0","cc","memory"); }
static void ex_initsem(struct GKExec *ex, APTR sem)
{ register struct GKExec *__e __asm("a6") = ex;
  register APTR __s __asm("a0") = sem;
  __asm volatile("jsr a6@(-558)\n" ::"r"(__e),"r"(__s):"d0","d1","a1","cc","memory"); }
static void ex_obtainsem(struct GKExec *ex, APTR sem)
{ register struct GKExec *__e __asm("a6") = ex;
  register APTR __s __asm("a0") = sem;
  __asm volatile("jsr a6@(-564)\n" ::"r"(__e),"r"(__s):"d0","d1","a1","cc","memory"); }
static void ex_releasesem(struct GKExec *ex, APTR sem)
{ register struct GKExec *__e __asm("a6") = ex;
  register APTR __s __asm("a0") = sem;
  __asm volatile("jsr a6@(-570)\n" ::"r"(__e),"r"(__s):"d0","d1","a1","cc","memory"); }
static void ex_remove(struct GKExec *ex, APTR node)
{ register struct GKExec *__e __asm("a6") = ex;
  register APTR __n __asm("a1") = node;
  __asm volatile("jsr a6@(-252)\n" ::"r"(__e),"r"(__n):"d0","d1","a0","cc","memory"); }

/* ---- internal helpers ----------------------------------------------- */

/* open the three dependencies into the data-hunk slots; 1 iff all ok */
static int open_deps(void)
{
    gk_dos  = ex_openlib((struct GKExec *)gk_exec, gk_dosname, 40);
    gk_intu = ex_openlib((struct GKExec *)gk_exec, gk_intuname, 40);
    gk_util = ex_openlib((struct GKExec *)gk_exec, gk_utilname, 40);
    return (gk_dos && gk_intu && gk_util) ? 1 : 0;
}

/* close in reverse order, clearing each slot */
static void close_deps(void)
{
    if (gk_util) { ex_closelib((struct GKExec *)gk_exec, gk_util); gk_util = 0; }
    if (gk_intu) { ex_closelib((struct GKExec *)gk_exec, gk_intu); gk_intu = 0; }
    if (gk_dos)  { ex_closelib((struct GKExec *)gk_exec, gk_dos);  gk_dos  = 0; }
}

/* ---- library init (InitTable[3]; d0=lib, a0=seglist, a6=exec) -------- */
struct GKLib *gk_init(struct GKLib *lib __asm("d0"),
                       ULONG seglist __asm("a0"),
                       struct GKExec *exec __asm("a6"))
{
    gk_exec = exec;
    if (exec->AttnFlags & 2) {          /* AFF_68020 */
        gk_seglist = seglist;
        lib->lib_Revision = 3;
        ex_initsem(exec, lib->gk_sem);
        return lib;
    }
    ex_freemem(exec, (UBYTE *)lib - lib->lib_NegSize,
               (ULONG)lib->lib_NegSize + lib->lib_PosSize);
    return 0;
}

/* ---- LibOpen (-6) ---------------------------------------------------- */
struct GKLib *gk_open(struct GKLib *lib __asm("a6"))
{
    struct GKLib *ret = lib;
    UWORD old;
    ex_obtainsem((struct GKExec *)gk_exec, lib->gk_sem);
    old = lib->lib_OpenCnt;
    lib->lib_OpenCnt = old + 1;
    lib->lib_Flags &= ~8;
    if (old == 0 && !open_deps()) {
        close_deps();
        ret = 0;
        lib->lib_OpenCnt--;
    }
    ex_releasesem((struct GKExec *)gk_exec, lib->gk_sem);
    return ret;
}

/* ---- LibExpunge (-18) ------------------------------------------------- */
ULONG gk_expunge(struct GKLib *lib __asm("a6"))
{
    ULONG seg = 0;
    if (lib->lib_OpenCnt == 0) {
        seg = gk_seglist;
        ex_remove((struct GKExec *)gk_exec, lib);
        ex_freemem((struct GKExec *)gk_exec,
                   (UBYTE *)lib - lib->lib_NegSize,
                   (ULONG)lib->lib_NegSize + lib->lib_PosSize);
    } else {
        lib->lib_Flags |= 8;
    }
    return seg;
}

/* ---- LibClose (-12) --------------------------------------------------- */
ULONG gk_close(struct GKLib *lib __asm("a6"))
{
    ULONG seg = 0;
    ex_obtainsem((struct GKExec *)gk_exec, lib->gk_sem);
    if (lib->lib_OpenCnt == 1)
        close_deps();
    lib->lib_OpenCnt--;
    ex_releasesem((struct GKExec *)gk_exec, lib->gk_sem);
    if (lib->lib_OpenCnt == 0 && (lib->lib_Flags & 8))
        seg = gk_expunge(lib);
    return seg;
}

/* ---- -24 reserved ------------------------------------------------------ */
ULONG gk_resv(void) { return 0; }

/* ---- -54 socket probe ---------------------------------------------------
 * Requires genesis.library v3 present (opened then closed again),
 * returns the bsdsocket.library v4 base or NULL.
 */
APTR gk_check(void)
{
    APTR g = ex_openlib((struct GKExec *)gk_exec, gk_genesisname, 3);
    if (!g)
        return 0;
    ex_closelib((struct GKExec *)gk_exec, g);
    return ex_openlib((struct GKExec *)gk_exec, gk_sockname, 4);
}

/* ---- -66 / -78: hunk-1 offsets of the embedded key strings ------------ */
ULONG gk_retserial(void) { return 0x20; }   /* offset of "454545"       */
ULONG gk_retos(void)     { return 0x120; }  /* offset of "AmigaOS 3.9"  */

/* ---- eight empty stubs (-30..-48, -60, -72, -84, -90) ----------------- */
void gk_e1(void) {}
void gk_e2(void) {}
void gk_e3(void) {}
void gk_e4(void) {}
void gk_e5(void) {}
void gk_e6(void) {}
void gk_e7(void) {}
void gk_e8(void) {}
