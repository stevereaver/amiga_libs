/*
**	asl.c -- _asl.library 40.6 ("$VER: _asl.library 40.6")
**
**	C reconstruction of the shipped binary "_asl._40.6.library".
**
**	A proxy/shim library: each of the six public vectors
**	(-30..-60) opens the real "asl.library" (version 36) via a
**	function pointer stored at libbase+0x22, calls the matching
**	LVO on the real base, closes it again, and returns the
**	result.  See asl_relay.s for the stubs.
**
**	Library base (dataSize 0x2e):
**	  0x00  struct Library
**	  0x22  OpenLibrary function pointer  -- never initialised
**	        by the library itself (see okf findings)
**	  0x26  "asl.library" string pointer  (InitStruct)
**	  0x2a  segment list                  (init routine)
**
**	Exec calls use the absolute ExecBase at $0004, as the
**	original does.
*/

#define EXEC_BASE_NAME (*(struct ExecBase **)4UL)

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <inline/exec.h>

struct AslShimBase {
    struct Library  sh_Lib;      /* 0x00-0x21 */
    APTR            sh_OpenFunc; /* 0x22: OpenLibrary ptr (uninitialised) */
    STRPTR          sh_RealName; /* 0x26: "asl.library" via InitStruct */
    ULONG           sh_SegList;  /* 0x2a */
};                               /* dataSize = 0x2e */

static ULONG DoExpunge(struct AslShimBase *base)
{
    ULONG seglist;

    if (base->sh_Lib.lib_OpenCnt) {
        base->sh_Lib.lib_Flags |= LIBF_DELEXP;
        return 0;
    }
    Remove((struct Node *)base);
    seglist = base->sh_SegList;
    FreeMem((UBYTE *)base - base->sh_Lib.lib_NegSize,
            (ULONG)base->sh_Lib.lib_NegSize + base->sh_Lib.lib_PosSize);
    return seglist;
}

/* init: d0 = base, a0 = seglist -> +0x2a; returns d0 = base */
struct Library *LibInit(register struct AslShimBase *base __asm("d0"),
                        register ULONG seglist __asm("a0"));

struct Library *LibInit(register struct AslShimBase *base __asm("d0"),
                        register ULONG seglist __asm("a0"))
{
    base->sh_SegList = seglist;
    return (struct Library *)base;
}

/* LVO -6: OpenCnt++, clear DELEXP, return base */
struct Library *LibOpen(void);
struct Library *LibOpen(void)
{
    register struct AslShimBase *base __asm("a6");
    base->sh_Lib.lib_OpenCnt++;
    base->sh_Lib.lib_Flags &= ~LIBF_DELEXP;
    return (struct Library *)base;
}

/* LVO -12: OpenCnt--, expunge on 0 + DELEXP; returns seglist or 0 */
ULONG LibClose(void);
ULONG LibClose(void)
{
    register struct AslShimBase *base __asm("a6");
    ULONG seg = 0;

    if (--base->sh_Lib.lib_OpenCnt == 0 &&
        (base->sh_Lib.lib_Flags & LIBF_DELEXP))
        seg = DoExpunge(base);
    return seg;
}

/* LVO -18 */
ULONG LibExpunge(void);
ULONG LibExpunge(void)
{
    register struct AslShimBase *base __asm("a6");
    return DoExpunge(base);
}

/* LVO -24 (reserved): null stub */
LONG LibNull(void);
LONG LibNull(void)
{
    return 0;
}
