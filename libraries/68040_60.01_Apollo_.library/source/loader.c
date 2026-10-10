/*
**	loader.c -- C reconstruction of the Apollo
**	68040.library 60.01 loader stub
**	($VER:68o4o/68060.library-loader 60.01 (08 Dec 1995 Z.Urwani))
**
**	The library is a pure loader: it implements only the four
**	system vectors (Open/Close/Expunge/ExtFunc) and its init
**	function OpenLibrary()s the real CPU-support library so that
**	it becomes resident.  The library base is a bare struct
**	Library (dataSize 0x22) with no private fields -- the opened
**	library is deliberately never closed so it stays in exec's
**	library list, and this stub itself answers
**	OpenLibrary("68040.library").
**
**	Init logic recovered from the disassembly:
**	  - requires AFB_68040 set in ExecBase->AttnFlags, else fail
**	  - fails when AttnFlags == 0x80ff (all low-byte flag bits +
**	    AFB_PRIVATE -- an unusual, probably emulated, config)
**	  - with AFF_FPU40 set:   OpenLibrary("68o4o.library",0)
**	  - without AFF_FPU40:    OpenLibrary("68060.library",0)
**	  - fails when the open fails, returns the base otherwise
**
**	Note "68o4o.library" really is spelled with a letter 'o'
**	in the binary.
*/

#include <exec/types.h>
#include <exec/execbase.h>
#include <exec/libraries.h>
#include <exec/resident.h>
#include <dos/dos.h>

/* file-scope SysBase copy: this library is a single instance and
   LibInit is called exactly once by InitResident/MakeLibrary */
static struct ExecBase *SB;

#define EXEC_BASE_NAME SB
#include <proto/exec.h>

/* library names emitted by loader_lib.s (C name gets a '_' prefix,
   so these externs resolve to _str_68o4o / _str_68060) */
extern const char str_68o4o[];
extern const char str_68060[];

struct Library *LibInit(struct Library *base __asm("d0"),
                        BPTR seglist __asm("a0"));
struct Library *LibOpen(void);
LONG LibClose(void);
LONG LibExpunge(void);

/*
 * LibInit: InitResident calls with d0=base, a0=seglist, a6=SysBase.
 * The base is only 34 bytes (no room for seglist/sysbase fields);
 * the original stores nothing.
 */
struct Library *LibInit(struct Library *base __asm("d0"),
                        BPTR seglist __asm("a0"))
{
    register struct ExecBase *sysbase __asm("a6"); /* entry a6 = SysBase */
    struct Library *res;

    (void)seglist;
    SB = sysbase;

    if (!(sysbase->AttnFlags & AFF_68040))
        return NULL;
    if (sysbase->AttnFlags == 0x80ff)
        return NULL;

    if (sysbase->AttnFlags & AFF_FPU40)
        res = OpenLibrary((CONST_STRPTR)str_68o4o, 0);
    else
        res = OpenLibrary((CONST_STRPTR)str_68060, 0);
    if (!res)
        return NULL;

    return base;
}

/* LibOpen (LVO -6): OpenCnt++, return the base itself. */
struct Library *LibOpen(void)
{
    register struct Library *base __asm("a6"); /* a6 = library base */

    base->lib_OpenCnt++;
    return base;
}

/* LibClose (LVO -12): OpenCnt--, return 0 (never expunges). */
LONG LibClose(void)
{
    register struct Library *base __asm("a6");

    base->lib_OpenCnt--;
    return 0;
}

/* LibExpunge (LVO -18), also used as ExtFunc (LVO -24) stub. */
LONG LibExpunge(void)
{
    return 0;
}
