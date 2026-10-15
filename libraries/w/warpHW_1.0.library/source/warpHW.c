/*
**	warpHW.c -- warpHW.library 1.0
**	"WarpUp hardware driver for BlizzardPPC" (10-Apr-98)
**
**	C reconstruction of the shipped SAS/C far-data build.
**	This is a BlizzardPPC hardware driver: the 68k side
**	exposes helpers that walk SysBase for the PPC address
**	window and poke the CSPPC control registers mapped at
**	$00f6xxxx.  It also carries a small PowerPC routine
**	(emitted as a data blob) that a PPC task can call.
**
**	  -30 whwDesc()	returns the driver descriptor struct
**	  -36 whwVer()	returns 1
**	  -42 whwFindIO()	walks the list at SysBase+322,
**			returns the entry whose [20]>=0x40000000
**			and [24]<0x80000000 (the PPC window)
**	  -48 whwPoke3()	BlizzardPPC register sequence
**	  -54 whwPoke4()	write $01 to $f60038
**	  -60 whwPPC()		pointer to the PPC code blob
**
**	External calls: exec -252 Remove, -210 FreeMem only.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <dos/dos.h>

extern ULONG wh_sys;		/* far-data: SysBase	    */
extern ULONG wh_seg;		/* far-data: seglist	    */
extern const ULONG wh_desc[];
extern const UBYTE  wh_ppc[];

#define SYSBASE	(*(struct ExecBase **)4)

/* ------------------------------------------------------------------ */
/* exec calls							  */
/* ------------------------------------------------------------------ */

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile ("jsr %/a6@(-252:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __FreeMem(__blk, ___size) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_blk __asm("a1") = (APTR)(__blk);\
  register ULONG __p_d0 __asm("d0") = (ULONG)(___size);\
  __asm volatile ("jsr %/a6@(-210:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_blk), "d"(__p_d0), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );})

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

struct Library *LibOpen(struct Library *base __asm("a6"))
{
    base->lib_OpenCnt++;
    base->lib_Flags &= ~LIBF_DELEXP;
    return base;
}

BPTR LibExpunge(struct Library *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->lib_OpenCnt) {
	base->lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    seg = (BPTR)wh_seg;
    __Remove(sys, &base->lib_Node);
    __FreeMem((UBYTE *)base - base->lib_NegSize,
	      (ULONG)base->lib_NegSize + base->lib_PosSize);

    return seg;
}

LONG LibClose(struct Library *base __asm("a6"))
{
    if (--base->lib_OpenCnt == 0) {
	if (base->lib_Flags & LIBF_DELEXP)
	    return (LONG)LibExpunge(base);
    }
    return 0;
}

/* ------------------------------------------------------------------ */
/* public functions						  */
/* ------------------------------------------------------------------ */

/* -30: return the driver descriptor struct			*/
const void *whwDesc(void)
{
    return wh_desc;
}

/* -36: returns 1							*/
LONG whwVer(void)
{
    return 1;
}

/* -42: walk the singly-linked list at SysBase+322 and return
 * entry[24] (the upper bound) of the node whose [20] is in the
 * PPC window 0x40000000..0x7fffffff.  Returns 0 if none.	   */
ULONG whwFindIO(void)
{
    struct ExecBase *sys = SYSBASE;
    ULONG *node = *(ULONG **)((UBYTE *)sys + 322);

    while (node && node[0]) {
	if (node[5] >= 0x40000000 && node[6] < 0x80000000)
	    return node[6];
	node = (ULONG *)node[0];
    }
    return 0;
}

/* small settle delay (the original's LAB_0026 NOP;RTS)	*/
static void settle(void)
{
    __asm volatile ("nop");
}

/* -48: BlizzardPPC register-write sequence.  Bytes written
 * to the $f6xxxx CSPPC control registers, with settle delays
 * (the original writes MOVE.B #imm,(A0) interleaved with
 * BSR LAB_0026 delays).					      */
void whwPoke3(void)
{
    settle();
    *(volatile UBYTE *)0xf60000 = 0x10;
    settle();
    *(volatile UBYTE *)0xf60028 = 0x82;
    *(volatile UBYTE *)0xf60038 = 0xff;
    *(volatile UBYTE *)0xf60030 = 0x87;
    *(volatile UBYTE *)0xf60008 = 0xa8;
    settle();
    *(volatile UBYTE *)0xf60008 = 0x10;
    settle();
    *(volatile UBYTE *)0xf60000 = 0x90;
    *(volatile UBYTE *)0xf60028 = 0x02;
    *(volatile UBYTE *)0xf60030 = 0x40;
    settle();
}

/* -54: write $01 to $f60038					*/
void whwPoke4(void)
{
    settle();
    *(volatile UBYTE *)0xf60038 = 0x01;
    settle();
}

/* -60: return the embedded PowerPC routine			 */
const void *whwPPC(void)
{
    return wh_ppc;
}
