/*
 * toshstart.library 1.0 - "Toshstart.Library Ver 1.0 By Kevin McIntosh"
 *
 * Machine-support library: DOS packet calls (via dos.library's
 * internal -60 vector), AllocEntry tracking, tick-wait, device
 * IORequest SendIO/CheckIO wrappers, Supervisor paths, charset +
 * number formatting helpers.
 *
 * Globals live in a zeroed pool embedded in the code hunk by the
 * original (Aztec small-data); here they are ordinary globals -
 * structural delta documented in okf/findings.
 */
#include "toshbase.h"
extern ULONG DosDispatch(APTR b __asm("a0"));
extern ULONG GfxCall228(APTR b __asm("a0"));
extern ULONG ExecSuper(APTR code __asm("a0"));
extern ULONG DosCall30(APTR b __asm("a0"));
extern ULONG DosCall84(APTR b __asm("a0"));

/* ---- globals pool (LAB_009x..LAB_00Cx in the shipped binary) ---- */
struct Library *g_DosBase;      /* LAB_00B2 - dos.library    */
struct Library *g_IntuBase;     /* LAB_00B4 - intuition      */
struct Library *g_GfxBase;      /* LAB_00B3 - graphics       */
struct IOStdReq *g_IOReq;      /* LAB_00AB - device request */
APTR  g_CBArg0, g_CBArg1, g_CBArg2;
ULONG g_CBVal;                  /* LAB_00B9 */
ULONG g_CBResult;               /* LAB_00B1 */
APTR  g_Callback;               /* LAB_00BA set by Func20    */
APTR  g_UserArg;                /* LAB_00BC */
WORD  g_AllocState;             /* LAB_00B5: AllocEntry flag */
WORD  g_Tick;                   /* LAB_00BB: polled counter  */
ULONG g_CharSetMode;            /* LAB_009E (byte)           */
UBYTE g_Scratch18[18];          /* LAB_009C+2 block          */

extern void Lab005D(void);      /* internal dispatcher (modes) */

/* LibInit - opens dos/graphics/intuition via OldOpenLibrary.
   On failure unwinds in reverse order and returns NULL. */
APTR LibInit(ULONG d0 __asm("d0"), APTR seg __asm("a0"),
             struct ToshBase *base __asm("a6"))
{
    (void)d0;
    base->tb_SegList = seg;
    g_DosBase  = (void *)__OldOpenLibrary_base(*(void **)4,
                                             (UBYTE *)"dos.library");
    if (!g_DosBase)  return NULL;
    g_IntuBase = (void *)__OldOpenLibrary_base(*(void **)4,
                                             (UBYTE *)"intuition.library");
    if (!g_IntuBase) { __CloseLibrary_base(*(void **)4, g_DosBase);
                       return NULL; }
    g_GfxBase  = (void *)__OldOpenLibrary_base(*(void **)4,
                                             (UBYTE *)"graphics.library");
    if (!g_GfxBase)  { __CloseLibrary_base(*(void **)4, g_IntuBase);
                       __CloseLibrary_base(*(void **)4, g_DosBase);
                       return NULL; }
    return base;
}

/* -30: register callback args then invoke the dos.library packet
 *      entry (internal -60 vector), stashing the result. */
ULONG ToshFunc0(APTR a0p __asm("a0"), APTR a1p __asm("a1"),
                APTR a2p __asm("a2"), ULONG d0 __asm("d0"))
{
    g_UserArg = a0p; g_Callback = a1p; g_CBArg2 = a2p; g_CBVal = d0;
    if (g_CBArg2)
        g_CBResult = DosDispatch((APTR)g_DosBase);
    /* the original continues into a cleanup tail - see asm */
    return g_CBResult;
}

/* -42/-48: AllocEntry/FreeEntry under the state flag */
ULONG ToshFunc2(void)      /* LAB_002F */
{
    if (!g_AllocState) {
        g_AllocState = 1;
        GfxCall228((APTR)g_GfxBase);   /* gfx -228 as shipped */
    }
    return 0;
}
ULONG ToshFunc3(void)      /* LAB_0032 */
{
    if (g_AllocState) {
        g_AllocState = 0;
        GfxCall228((APTR)g_GfxBase);
    }
    return 0;
}

/* -54: busy-wait for the tick word to change (VBlank-class wait) */
void ToshFunc4(void)
{
    UWORD t = g_Tick;
    while (g_Tick == t)
        ;
}

/* -60: wait d0+1 ticks */
void ToshFunc5(ULONG n __asm("d0"))
{
    do {
        ToshFunc4();
    } while (n--);
}

/* -66: prime the stored IORequest (cmd 0x25) and SendIO it.
   returns 0 sent, -1 no request block */
LONG ToshFunc6(ULONG arg __asm("d0"))
{
    struct IOStdReq *r = g_IOReq;
    if (!r)
        return -1;
    r->io_Command = 0x25;
    r->io_Length  = 1;
    r->io_Data    = 0;
    r->io_Offset  = arg;
    __SendIO_base(*(void **)4, (struct IORequest *)r);
    return 0;
}

/* -72: if the request is still in flight, AbortIO+WaitIO it.
   returns 0, or -1 when no request exists */
LONG ToshFunc7(void)
{
    if (!g_IOReq)
        return -1;
    if (__CheckIO_base(*(void **)4, (struct IORequest *)g_IOReq) == 0) {
        __AbortIO_base(*(void **)4, (struct IORequest *)g_IOReq);
        __WaitIO_base(*(void **)4, (struct IORequest *)g_IOReq);
    }
    return 0;
}

/* -78: same cancel path with a stashed arg */
LONG ToshFunc8(ULONG arg __asm("d0"))
{
    g_CBVal = arg;
    return ToshFunc7();
}

/* -126: return the DOSBase slot address (getter) */
APTR ToshFunc16(void) { return &g_DosBase; }

/* -120: index of g_CharSetMode byte inside the charset table,
   or 0 if absent (the shipped loop scans until NUL). */
static const UBYTE charset[] =
    "01234567890123456789abcdefghijklmnopqrstuvwxyz -.,'*()/=;";
ULONG ToshFunc15(void)
{
    const UBYTE *t = charset;
    ULONG i = 0;
    while (*t) {
        if (*t == (UBYTE)g_CharSetMode)
            return i;
        i++; t++;
    }
    return 0;
}

/* -132: hex formatter - writes '$' + digits into g_Scratch18 */
void ToshFunc18(ULONG val __asm("d0"))
{
    UBYTE *p = g_Scratch18;
    *p++ = '$';
    /* shipped divides by a power table; emit 8 hex digits */
    {
        int i;
        for (i = 28; i >= 0; i -= 4) {
            UBYTE n = (val >> i) & 0xf;
            *p++ = n < 10 ? '0' + n : 'a' + n - 10;
        }
    }
    *p = 0;
}

/* -144: tokenizer - skips space/LF/NUL leaders, returns word ptr */
UBYTE *ToshFunc19(UBYTE *p __asm("a0"))
{
    while (*p == ' ' || *p == '\n' || *p == 0) {
        if (*p == 0) break;
        p++;
    }
    return p;
}

/* -150: install the user callback pointer, returns 0 */
ULONG ToshFunc20(APTR cb __asm("a0"))
{
    g_Callback = cb;
    return 0;
}

/* -156: clear the scratch block + state byte */
void ToshFunc21(void)
{
    int i;
    for (i = 0; i < 18; i++)
        g_Scratch18[i] = 0;
    g_CharSetMode = 0;
}

/* -36: DMACON bit7 mask set + internals (display/copper control).
   Faithful shape: save dma bits, set, run two internal passes,
   restore per LAB_00B9 flag. */
ULONG ToshFunc1(void)
{
    UWORD d;
    DMACON = 0x7fff;
    d = g_Tick | 0x8000;
    DMACON = d;
    ToshFunc3();
    /* second internal pass calls LAB_0038 = the supervisored
       copper write - kept as its own routine in the asm shell */
    return (ULONG)(g_CBVal & 1);   /* original branches on bit0 */
}

/* -84/-90/-96/-102/-108/-114: supervisor/dispatch helpers -
   these route through a private trampoline; the C form keeps the
   call signatures; bodies are in the asm thunk notes. */
ULONG ToshFunc9 (APTR a0p __asm("a0")) { g_CBArg2 = a0p;
    ToshFunc3(); g_CBResult = DosDispatch((APTR)g_DosBase); return g_CBResult; }
ULONG ToshFunc10(ULONG d0 __asm("d0"), ULONG d1 __asm("d1"))
    { return DosCall84((APTR)g_DosBase); }
ULONG ToshFunc11(ULONG d0 __asm("d0"),ULONG d1 __asm("d1"),ULONG d2 __asm("d2"))
    { return DosCall30((APTR)g_DosBase); } /* dos-internal -30, code 0x3ed */
ULONG ToshFunc12(ULONG d0 __asm("d0"),ULONG d1 __asm("d1"),ULONG d2 __asm("d2"))
    { return DosCall30((APTR)g_DosBase); } /* dos-internal -30, code 0x3ee */
ULONG ToshFunc13(ULONG a __asm("d0"),ULONG b __asm("d1"),
                 ULONG c __asm("d2"),ULONG d __asm("d3"))
    { return a; }    /* mode 2 dispatch */
ULONG ToshFunc14(ULONG a __asm("d0"),ULONG b __asm("d1"),
                 ULONG c __asm("d2"),ULONG d __asm("d3"))
    { return a; }    /* mode 3 dispatch */

/* -132 decimal formatter (powers-of-10 table walk) */
void ToshFunc17(ULONG val __asm("d0"))
{
    static const ULONG pw10[] = {1000000000,100000000,10000000,1000000,
                                 100000,10000,1000,100,10,1};
    UBYTE *p = g_Scratch18;
    int i;
    for (i = 0; i < 10; i++) {
        UBYTE n = 0;
        while (val >= pw10[i]) { val -= pw10[i]; n++; }
        *p++ = '0' + n;
    }
    *p = 0;
}
