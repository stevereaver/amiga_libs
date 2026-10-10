/*
 * fwfiltertype.c -- C reconstruction of fwfiltertype.library 3.0
 * (SoftWood, Inc. 1993)
 *
 * Standard AUTOINIT library: 4 system vectors + one user function,
 * FwFilterType (LVO -30), plus a second reserved null slot (-36).
 * The library keeps no SysBase; Expunge uses the absolute exec base
 * (4.w), matching the original's "movea.l ABSEXECBASE,a6".
 */

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>
#include <proto/exec.h>
#include "fwbase.h"

#define ABSEXECBASE (*(struct ExecBase **)4)

/* InitVector: d0 = library base, a0 = seglist, a6 = SysBase */
struct FWFilterBase *LibInit(struct FWFilterBase *base __asm("d0"),
			      BPTR seglist __asm("a0"))
{
	base->fb_SegList = seglist;
	return base;
}

/* LibOpen (LVO -6): bump open count, clear deferred expunge, return base */
struct FWFilterBase *LibOpen(struct FWFilterBase *base __asm("a6"))
{
	base->fb_Lib.lib_OpenCnt++;
	base->fb_Lib.lib_Flags &= ~LIBF_DELEXP;
	return base;
}

APTR LibExpunge(struct FWFilterBase *base __asm("a6"));

/* LibClose (LVO -12): decrement open count; expunge if deferred */
APTR LibClose(struct FWFilterBase *base __asm("a6"))
{
	if (--base->fb_Lib.lib_OpenCnt == 0 &&
	    (base->fb_Lib.lib_Flags & LIBF_DELEXP))
		return LibExpunge(base);
	return NULL;
}

/*
 * LibExpunge (LVO -18): deferred expunge while busy; otherwise Remove()
 * the node, free the base block (NegSize + PosSize), return the seglist
 * via the original's base+0x24 helper.
 */
APTR LibExpunge(struct FWFilterBase *base __asm("a6"))
{
	APTR    seglist;
	UBYTE  *block;
	ULONG   size;

	if (base->fb_Lib.lib_OpenCnt != 0) {
		base->fb_Lib.lib_Flags |= LIBF_DELEXP;
		return NULL;
	}

	seglist = (APTR)(ULONG)base->fb_SegList;

	__Remove_base(ABSEXECBASE, (struct Node *)base);

	block = (UBYTE *)base - base->fb_Lib.lib_NegSize;
	size  = (ULONG)base->fb_Lib.lib_NegSize + base->fb_Lib.lib_PosSize;
	__FreeMem_base(ABSEXECBASE, block, size);

	return seglist;
}

/* LibNull (LVO -24 and -36, reserved slots): always returns 0 */
APTR LibNull(void)
{
	return NULL;
}

/*
 * FwFilterType -- the library's only user function (LVO -30).
 *
 * Compares the 4 type bytes at (field + 0x0c) against "alph".
 * On a match returns 3 and, if 'out' is non-NULL, stores a pointer
 * to the replacement type string "fwpha" in *out.  Returns 0 on
 * no match.  The d0 argument is accepted but ignored in the
 * original (saved, never read); the original also emits a dead
 * cmpi.w #$4294,d0 whose flags are never consumed.
 */
ULONG FwFilterType(UBYTE *field __asm("a0"),
		    STRPTR *out __asm("a1"),
		    ULONG unused __asm("d0"))
{
	ULONG result = 0;
	UWORD i;

	for (i = 0; i < 4 && field[0x0c + i] == "alpha"[i]; i++)
		;
	if (i == 4)
		result = 3;

	if (out != NULL && result == 3)
		*out = (STRPTR)"fwpha";

	return result;
}
