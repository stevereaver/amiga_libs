/* amisslmaster.library 5.27 (wolfSSL-Wrapper) -- reconstruction
 *
 * Compiled-C library (original built by a C compiler: stack-passed
 * args, pea/jsr internal calls).  Wraps amissl.library: OpenAmiSSL*
 * open the real library once, OpenAmiSSLTagList either calls
 * amissl's InitAmiSSLA (LVO -36) or just hands back the base pointer.
 *
 * Every entry point also writes a debug line to "RAM:awmaster.log"
 * through a helper that does Open/Seek(END)/Write/Close per call.
 *
 * Lib private data (dataSize 50):
 *   +34 ExecBase  +38 SegList  +42 AmiSSLBase  +46 DOSBase
 */

typedef unsigned long  ULONG;
typedef long           LONG;
typedef unsigned short UWORD;
typedef unsigned char  UBYTE;
typedef char          *STRPTR;
typedef void          *APTR;

struct TagItem { ULONG ti_Tag; ULONG ti_Data; };

#define REG(reg)  __asm(reg)

extern const char libname[], idstr[], dosname[], amisslname[], lognam[];

/*---------------------------- lib fields --------------------------*/
/* accessed as a6-relative longs in the original */
#define LIB_EXECB(lib)   (*(APTR *)((UBYTE *)(lib) + 34))
#define LIB_SEGL(lib)    (*(APTR *)((UBYTE *)(lib) + 38))
#define LIB_AMISSL(lib)  (*(APTR *)((UBYTE *)(lib) + 42))
#define LIB_DOS(lib)     (*(APTR *)((UBYTE *)(lib) + 46))
#define LIB_OPENCNT(lib) (*(UWORD *)((UBYTE *)(lib) + 32))
#define LIB_FLAGS(lib)   (*(UBYTE *)((UBYTE *)(lib) + 14))
#define LIB_NEGSZ(lib)   (*(UWORD *)((UBYTE *)(lib) + 16))
#define LIB_POSSZ(lib)   (*(UWORD *)((UBYTE *)(lib) + 18))

/*---------------------------- exec stubs --------------------------*/
static APTR exec_OpenLibrary(STRPTR n, ULONG v, APTR sb)
{   register APTR r REG("d0"); register STRPTR a1 REG("a1") = n;
    register ULONG d0 REG("d0") = v; register APTR a6 REG("a6") = sb;
    __asm volatile("jsr a6@(-552)" : "=r"(r) : "r"(a1),"r"(d0),"r"(a6)
                   : "memory","cc");
    return r; }
static void exec_CloseLibrary(APTR l, APTR sb)
{   register APTR a1 REG("a1") = l; register APTR a6 REG("a6") = sb;
    __asm volatile("jsr a6@(-414)" :: "r"(a1),"r"(a6)
                   : "memory","cc"); }
static void exec_Remove(APTR n, APTR sb)
{   register APTR a1 REG("a1") = n; register APTR a6 REG("a6") = sb;
    __asm volatile("jsr a6@(-252)" :: "r"(a1),"r"(a6)
                   : "memory","cc"); }
static void exec_FreeMem(APTR p, ULONG sz, APTR sb)
{   register APTR a1 REG("a1") = p; register ULONG d0 REG("d0") = sz;
    register APTR a6 REG("a6") = sb;
    __asm volatile("jsr a6@(-210)" :: "r"(a1),"r"(d0),"r"(a6)
                   : "memory","cc"); }
static void exec_Forbid(APTR sb)
{   register APTR a6 REG("a6") = sb;
    __asm volatile("jsr a6@(-132)" :: "r"(a6)
                   : "memory","cc"); }
static void exec_Permit(APTR sb)
{   register APTR a6 REG("a6") = sb;
    __asm volatile("jsr a6@(-138)" :: "r"(a6)
                   : "memory","cc"); }

/*---------------------------- dos stubs ---------------------------*/
static LONG dos_Open(STRPTR name, LONG mode, APTR db)
{   register LONG r REG("d0"); register STRPTR d1 REG("d1") = name;
    register LONG d2 REG("d2") = mode; register APTR a6 REG("a6") = db;
    __asm volatile("jsr a6@(-30)" : "=r"(r) : "r"(d1),"r"(d2),"r"(a6)
                   : "memory","cc");
    return r; }
static void dos_Close(LONG fh, APTR db)
{   register LONG d1 REG("d1") = fh; register APTR a6 REG("a6") = db;
    __asm volatile("jsr a6@(-36)" :: "r"(d1),"r"(a6)
                   : "memory","cc"); }
static void dos_Write(LONG fh, APTR buf, LONG len, APTR db)
{   register LONG d1 REG("d1") = fh; register APTR d2 REG("d2") = buf;
    register LONG d3 REG("d3") = len; register APTR a6 REG("a6") = db;
    __asm volatile("jsr a6@(-48)" :: "r"(d1),"r"(d2),"r"(d3),"r"(a6)
                   : "memory","cc"); }
static void dos_Seek(LONG fh, LONG off, LONG mode, APTR db)
{   register LONG d1 REG("d1") = fh; register LONG d2 REG("d2") = off;
    register LONG d3 REG("d3") = mode; register APTR a6 REG("a6") = db;
    __asm volatile("jsr a6@(-66)" :: "r"(d1),"r"(d2),"r"(d3),"r"(a6)
                   : "memory","cc"); }

/*--------------------------- debug logger -------------------------*/
/* log(ctx=lib+46 DOSBase, fmt, val, flag)
 *
 * Builds a line in a stack buffer: fmt (max ~70 chars) then, when
 * flag is set, " = <val>" (signed decimal).  Appends '\n' and writes
 * the line by opening "RAM:awmaster.log" (MODE_READWRITE 1004, else
 * MODE_NEWFILE 1006), Seek(0,OFFSET_END), Write, Close.
 */
static void awlog(APTR dosb, const char *fmt, LONG val, LONG flag)
{
    char buf[96];
    LONG len = 0;
    LONG fh;

    if (!dosb) return;
    if (fmt) {
        int i = 70;                     /* dbf cap: up to 71 chars */
        char c;
        while ((c = *fmt++) != 0) { buf[len++] = c; if (!--i) break; }
    }
    if (flag) {
        ULONG u;
        char tmp[12]; int n = 0;
        buf[len++] = ' '; buf[len++] = '='; buf[len++] = ' ';
        if (val < 0) { buf[len++] = '-'; u = (ULONG)(-val); }
        else u = (ULONG)val;
        do {
            ULONG q, r;
            __asm("divul.l #10,%1:%0" : "=d"(q),"=d"(r) : "0"(u),"1"(0));
            tmp[n++] = '0' + (int)r; u = q;
        } while (u);
        while (n) buf[len++] = tmp[--n];
    }
    buf[len++] = '\n';

    fh = dos_Open((STRPTR)lognam, 1004, dosb);       /* MODE_READWRITE */
    if (!fh) fh = dos_Open((STRPTR)lognam, 1006, dosb); /* NEWFILE */
    if (!fh) return;
    dos_Seek(fh, 0, 1, dosb);                               /* OFFSET_END */
    dos_Write(fh, buf, len, dosb);
    dos_Close(fh, dosb);
}

/*--------------------------- lifecycle ----------------------------*/
/* mLibInit(d0=lib, a0=seglist, a6=sysbase): fills the Library header
 * itself (datatab is NULL in the InitTable) and opens dos.library. */
APTR mLibInit(register APTR lib REG("d0"), register APTR seg REG("a0"),
               register APTR sysb REG("a6"))
{
    LIB_EXECB(lib) = sysb;
    LIB_SEGL(lib)  = seg;
    LIB_AMISSL(lib)= 0;
    LIB_DOS(lib)   = exec_OpenLibrary((STRPTR)dosname, 36, sysb);

    *(UBYTE *)((UBYTE *)lib + 8)  = 9;                 /* NT_LIBRARY   */
    *(APTR  *)((UBYTE *)lib + 10) = (APTR)libname;    /* ln_Name      */
    LIB_FLAGS(lib)                = 6;
    *(UWORD *)((UBYTE *)lib + 20) = 5;                 /* version      */
    *(UWORD *)((UBYTE *)lib + 22) = 27;                /* revision     */
    *(APTR  *)((UBYTE *)lib + 24) = (APTR)idstr;
    return lib;
}

APTR mLibOpen(register APTR lib REG("a6"))
{
    exec_Forbid(LIB_EXECB(lib));
    LIB_OPENCNT(lib)++;
    LIB_FLAGS(lib) &= ~8;                              /* clr DELEXP   */
    exec_Permit(LIB_EXECB(lib));
    return lib;
}

/* shared expunge worker — called from Close and Expunge */
static APTR expunge_worker(APTR lib)
{
    APTR seg;
    if (LIB_OPENCNT(lib) == 0) {
        APTR a = LIB_AMISSL(lib);
        if (a) { exec_CloseLibrary(a, LIB_EXECB(lib)); LIB_AMISSL(lib) = 0; }
        seg = LIB_SEGL(lib);
        exec_Remove(lib, LIB_EXECB(lib));
        exec_FreeMem((UBYTE *)lib - LIB_NEGSZ(lib),
                     LIB_NEGSZ(lib) + LIB_POSSZ(lib), LIB_EXECB(lib));
        return seg;
    }
    LIB_FLAGS(lib) |= 8;                               /* set DELEXP   */
    return 0;
}

APTR mLibClose(register APTR lib REG("a6"))
{
    APTR r;
    exec_Forbid(LIB_EXECB(lib));
    if (LIB_OPENCNT(lib)) {
        LIB_OPENCNT(lib)--;
        if (LIB_OPENCNT(lib)) {              /* still open -> ret 0 */
            exec_Permit(LIB_EXECB(lib));
            return 0;
        }
    }
    if (!(LIB_FLAGS(lib) & 8)) {             /* no deferred expunge */
        exec_Permit(LIB_EXECB(lib));
        return 0;
    }
    r = expunge_worker(lib);
    exec_Permit(LIB_EXECB(lib));
    return r;
}

APTR mLibExpunge(register APTR lib REG("a6"))
{
    APTR r;
    exec_Forbid(LIB_EXECB(lib));
    r = expunge_worker(lib);
    exec_Permit(LIB_EXECB(lib));
    return r;
}

LONG mLibNull(void) { return 0; }

/*------------------------------ API -------------------------------*/
/* rc codes observed in the original: 1 InitAmiSSLMaster ok,
 * 0 OpenAmiSSLTagList ok, 2 amisslBase unavailable, 3 InitAmiSSLA rc!=0 */

LONG InitAmiSSLMaster(register ULONG apiv REG("d0"), register APTR lib REG("a6"))
{
    awlog(LIB_DOS(lib), "InitAmiSSLMaster apiVersion", (LONG)apiv, 1);
    return 1;
}

APTR OpenAmiSSL(register ULONG apiv REG("d0"), register APTR lib REG("a6"))
{
    if (LIB_AMISSL(lib)) {
        awlog(LIB_DOS(lib), "OpenAmiSSL -> amisslBase",
              (LONG)LIB_AMISSL(lib), 1);
    } else {
        LIB_AMISSL(lib) = exec_OpenLibrary((STRPTR)amisslname, 0,
                                           LIB_EXECB(lib));
        awlog(LIB_DOS(lib), "OpenAmiSSL -> amisslBase",
              (LONG)LIB_AMISSL(lib), 1);
    }
    return LIB_AMISSL(lib);
}

void CloseAmiSSL(register APTR lib REG("a6"))
{
    APTR a = LIB_AMISSL(lib);
    if (a) { exec_CloseLibrary(a, LIB_EXECB(lib)); LIB_AMISSL(lib) = 0; }
}

LONG OpenAmiSSLCipher(void) { return 0; }   /* stub: always 0 */
void CloseAmiSSLCipher(void) { }            /* stub: bare rts  */

/* tags decoded from the original's tag-list walk */
#define TAG_CHAIN     3           /* ti_Data -> continue at Data+8  */
#define TAG_INITAMISSL 0x80000010 /* nonzero -> call InitAmiSSLA    */
#define TAG_BASEPTR    0x8000000d /* out-ptr slot for amisslBase    */

/* amissl.library -36 = InitAmiSSLA(tags, amisslBase) */
static LONG amissl_InitAmiSSLA(struct TagItem *tags, APTR amb)
{   register LONG r REG("d0"); register APTR a0 REG("a0") = tags;
    register APTR a1 REG("a1") = amb; register APTR a6 REG("a6") = amb;
    __asm volatile("jsr a6@(-36)" : "=r"(r) : "r"(a0),"r"(a1),"r"(a6)
                   : "memory","cc");
    return r; }

LONG OpenAmiSSLTagList(register ULONG apiv REG("d0"),
                        register struct TagItem *tags REG("a0"),
                        register APTR lib REG("a6"))
{
    struct TagItem *p;
    ULONG tag;

    awlog(LIB_DOS(lib), "OpenAmiSSLTagList apiVersion", (LONG)apiv, 1);
    if (!LIB_AMISSL(lib))
        LIB_AMISSL(lib) = exec_OpenLibrary((STRPTR)amisslname, 0,
                                           LIB_EXECB(lib));
    awlog(LIB_DOS(lib), "  amisslBase", (LONG)LIB_AMISSL(lib), 1);
    if (!LIB_AMISSL(lib)) return 2;

    if (tags) {
        p = tags;
        tag = p->ti_Tag;
        for (;;) {
            if (!tag) goto initamissl;
            if (tag == TAG_CHAIN) {         /* continue at ti_Data+8 */
                p = (struct TagItem *)((UBYTE *)p->ti_Data + 8);
                if (!p) goto initamissl;
                tag = p->ti_Tag;
                continue;
            }
            if (tag == TAG_INITAMISSL) break;
            p++;
            if (!p) goto initamissl;
            tag = p->ti_Tag;
        }
        if (p->ti_Data) goto initamissl;    /* InitAmiSSL=TRUE */

        /* InitAmiSSL=FALSE: rescan for the BasePtr out-tag */
        p = tags;
        tag = tags->ti_Tag;
        for (;;) {
            if (!tag) break;
            if (tag == TAG_CHAIN) {
                p = (struct TagItem *)((UBYTE *)p->ti_Data + 8);
                if (!p) break;
                tag = p->ti_Tag;
                continue;
            }
            if (tag == TAG_BASEPTR) {
                APTR *out = (APTR *)p->ti_Data;
                awlog(LIB_DOS(lib), "  Zweig: InitAmiSSL=FALSE, GetBasePtr",
                      (LONG)out, 1);
                if (out) *out = LIB_AMISSL(lib);
                awlog(LIB_DOS(lib), "OpenAmiSSLTagList -> 0 (OK)", 0, 0);
                return 0;
            }
            p++;
            if (!p) break;
            tag = p->ti_Tag;
        }
        awlog(LIB_DOS(lib), "  Zweig: InitAmiSSL=FALSE, GetBasePtr", 0, 1);
        awlog(LIB_DOS(lib), "OpenAmiSSLTagList -> 0 (OK)", 0, 0);
        return 0;
    }

initamissl:
    awlog(LIB_DOS(lib), "  Zweig: InitAmiSSL=TRUE -> rufe InitAmiSSLA", 0, 0);
    {
        LONG rc = amissl_InitAmiSSLA(tags, LIB_AMISSL(lib));
        awlog(LIB_DOS(lib), "  InitAmiSSLA rc", rc, 1);
        if (rc == 0) {
            awlog(LIB_DOS(lib), "OpenAmiSSLTagList -> 0 (OK)", 0, 0);
            return 0;
        }
        return 3;
    }
}
