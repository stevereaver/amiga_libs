/*
 * reqattack.library 0.03 -- "ReqAttack SubLibrary"
 * SAS/C-style manually-initialised library (RomTag has
 * RT_INIT = 0; a private loader uses the InitTable in
 * .data and MakeLibrary).
 *
 * This is a proxy library for the ReqAttack requester
 * auto-answering tool.  Its two public vectors wrap
 * intuition.library's EasyRequestArgs (-588) and
 * BuildEasyRequestArgs (-594): each call is first
 * forwarded to the "ReqAttack Warp Core" service
 * (located via its public message port, whose +46 field
 * holds a tiny jump-table base).  If the core returns -3
 * ("not handled") the real intuition function runs.
 *
 * A shared "ReqAttack SubLibrary" semaphore serialises
 * the hand-off.  The shipped code calls Forbid once but
 * Permit twice per invocation (TDNestCnt underflows by
 * one every call) -- preserved as shipped, see okf.
 *
 * Reconstructed in C from the shipped binary.
 */

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/lists.h>
#include <exec/ports.h>
#include <exec/semaphores.h>
#include <exec/execbase.h>
#include <dos/dos.h>

struct ReqBase
{
    struct Library	rb_Lib;		/* 34 bytes		   */
    BPTR		rb_SegList;	/* +0x22			   */
    ULONG		rb_Fixup[4];	/* +0x26..+0x37 far-data fixups */
};					/* total 0x38			   */

/* far-data globals (lib.s) */
extern ULONG	*ra_sysbase;	/* SysBase stash		   */
extern ULONG	*ra_intuition;	/* intuition.library base	   */
extern ULONG	*ra_warpcore;	/* WarpCore base (port+46)	   */
extern ULONG	 ra_fixup[];	/* SAS/C fixup table {0,0}	   */
extern char	 s_intuition[];	/* "intuition.library"		   */
extern char	 s_semname[];	/* "ReqAttack SubLibrary"	   */
extern char	 s_portname[];	/* "ReqAttack Warp Core"	   */
extern char	 libname[];	/* "reqattack.library"		   */
extern char	 idstr[];	/* "reqattack.library 0.03 ..."	   */

#define SYSBASE	(*((struct ExecBase **)&ra_sysbase))

/* ------------------------------------------------------------------ */
/* raw LVO helpers							  */
/* ------------------------------------------------------------------ */

#define EXEC_CALL(__lvo) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  __asm volatile ("jsr %/a6@(-" #__lvo ":W)"\
		   :\
		   : "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0", "a1" );})

#define EXEC_CALL1(__lvo, __a0) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_a0 __asm("a0") = (APTR)(__a0);\
  __asm volatile ("jsr %/a6@(-" #__lvo ":W)"\
		   :\
		   : "a"(__p_sys), "a"(__p_a0)\
		   : "cc", "memory", "d0", "d1", "a1" );})

#define EXEC_CALL1R(__lvo, __a1) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_a1 __asm("a1") = (APTR)(__a1);\
  register APTR __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-" #__lvo ":W)\n"\
		   : "=r"(__p_res)\
		   : "a"(__p_sys), "a"(__p_a1)\
		   : "cc", "memory", "d1", "a0" );\
  __p_res;})

#define EXEC_CALL1B(__lvo, __a0) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_a0 __asm("a0") = (APTR)(__a0);\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-" #__lvo ":W)\n"\
		   : "=r"(__p_res)\
		   : "a"(__p_sys), "a"(__p_a0)\
		   : "cc", "memory", "d1", "a1" );\
  __p_res;})

#define EXEC_CALL1L(__lvo, __a1) ({\
  register void * __p_sys __asm("a6") = SYSBASE;\
  register APTR __p_a1 __asm("a1") = (APTR)(__a1);\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-" #__lvo ":W)\n"\
		   : "=r"(__p_res)\
		   : "a"(__p_sys), "a"(__p_a1)\
		   : "cc", "memory", "d1", "a0" );\
  __p_res;})

/* intuition call through the stashed base */
#define INTUI_CALL(__lvo, __d1, __a0, __a1) ({\
  register void * __p_ib __asm("a6") = ra_intuition;\
  register LONG  __p_d1 __asm("d1") = (LONG)(__d1);\
  register APTR  __p_a0 __asm("a0") = (APTR)(__a0);\
  register APTR  __p_a1 __asm("a1") = (APTR)(__a1);\
  register LONG  __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-" #__lvo ":W)\n"\
		   : "=r"(__p_res)\
		   : "r"(__p_d1), "a"(__p_a0), "a"(__p_a1), "a"(__p_ib)\
		   : "cc", "memory", "d2", "d3", "a2", "a3" );\
  __p_res;})

/* WarpCore call -- a6 = the port+46 mini base */
#define WC_CALL(__lvo, __d1, __a0, __a1) ({\
  register void * __p_wc __asm("a6") = ra_warpcore;\
  register LONG  __p_d1 __asm("d1") = (LONG)(__d1);\
  register APTR  __p_a0 __asm("a0") = (APTR)(__a0);\
  register APTR  __p_a1 __asm("a1") = (APTR)(__a1);\
  register LONG  __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-" #__lvo ":W)\n"\
		   : "=r"(__p_res)\
		   : "r"(__p_d1), "a"(__p_a0), "a"(__p_a1), "a"(__p_wc)\
		   : "cc", "memory", "d2", "d3", "a2", "a3" );\
  __p_res;})

/* ------------------------------------------------------------------ */
/* library life cycle						  */
/* ------------------------------------------------------------------ */

static LONG OpenLibraries(struct ExecBase *sys __asm("a6"))
{
    struct Library *ib;

    ra_sysbase = (ULONG *)sys;		/* stash SysBase first    */
    ib = EXEC_CALL1R(552, s_intuition);	/* OpenLibrary(name,0)  */
    ra_intuition = (ULONG *)ib;
    return ib ? 0 : 1;
}

static void CloseLibraries(void)
{
    if (ra_intuition) {
	EXEC_CALL1(414, ra_intuition);	/* CloseLibrary	    */
	ra_intuition = 0;
    }
}

/*
**	init routine -- called by the private loader via
**	MakeLibrary; d0 = base, a0 = seglist, a6 = SysBase.
**	Writes the whole library header by hand (the manual
**	InitTable carries no dataTable).
*/
struct ReqBase *LibInit(struct ReqBase *b __asm("d0"),
			BPTR seg __asm("a0"),
			struct ExecBase *sys __asm("a6"))
{
    b->rb_SegList = seg;
    b->rb_Lib.lib_Node.ln_Type = NT_LIBRARY;
    b->rb_Lib.lib_Node.ln_Name = libname;
    b->rb_Lib.lib_Flags = 6;		/* LIBF_CHANGED|LIBF_SUMMUSED */
    b->rb_Lib.lib_Version = 0;
    b->rb_Lib.lib_Revision = 3;
    b->rb_Lib.lib_IdString = idstr;

    /* SAS/C far-data fixup: ra_fixup = {count, offs...};
       for each off: *(base+0x30+off) += base+0x30.
       The shipped table holds count 0 -- a template that
       never fires. */
    {
	ULONG *tab = &ra_fixup[1];	/* count at ra_fixup[1] */
	ULONG n = tab[0];
	ULONG *offs = tab + 1;		/* wrong but faithful:
					   the shipped code reads
					   the count at +4 then
					   indexes from +8 */
	while (n--) {
	    ULONG off = *offs++;
	    ULONG *p = (ULONG *)((UBYTE *)&b->rb_Lib + 0x30 + off);
	    *p += (ULONG)((UBYTE *)&b->rb_Lib + 0x30);
	}
    }

    if (OpenLibraries(sys))
	return 0;

    return b;
}

/*
**	-6 LibOpen
*/
struct ReqBase *LibOpen(struct ReqBase *b __asm("a6"))
{
    b->rb_Lib.lib_OpenCnt++;
    b->rb_Lib.lib_Flags &= ~LIBF_DELEXP;
    return b;
}

/*
**	-12 LibClose
*/
BPTR LibExpunge(struct ReqBase *b __asm("a6"));

LONG LibClose(struct ReqBase *b __asm("a6"))
{
    LONG res = 0;

    if (!--b->rb_Lib.lib_OpenCnt &&
	(b->rb_Lib.lib_Flags & LIBF_DELEXP))
	res = (LONG)LibExpunge(b);

    return res;
}

/*
**	-18 LibExpunge
*/
BPTR LibExpunge(struct ReqBase *b __asm("a6"))
{
    BPTR seg;

    if (b->rb_Lib.lib_OpenCnt) {
	b->rb_Lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    CloseLibraries();
    seg = b->rb_SegList;
    EXEC_CALL1(252, &b->rb_Lib.lib_Node);		/* Remove  */
    {
	register void * __p_sys __asm("a6") = SYSBASE;
	register APTR __p_blk __asm("a1") =
	    (UBYTE *)b - b->rb_Lib.lib_NegSize;
	register ULONG __p_sz __asm("d0") =
	    (ULONG)b->rb_Lib.lib_NegSize + b->rb_Lib.lib_PosSize;
	__asm volatile ("jsr %/a6@(-210:W)\n"
	    : : "a"(__p_sys), "a"(__p_blk), "d"(__p_sz)
	    : "cc", "memory", "a0" );
    }
    return seg;
}

/* ------------------------------------------------------------------ */
/* public vectors							  */
/* ------------------------------------------------------------------ */

/*
**	-30 RARequest -- proxy for intuition's
**	EasyRequestArgs (-588).
**
**	Forbid; FindSemaphore("ReqAttack SubLibrary");
**	AttemptSemaphoreShared; Permit; FindPort("ReqAttack
**	Warp Core") -> base = port+46; res = base[-30]
**	(d1,a0,a1); ReleaseSemaphore; Permit;  if res == -3
**	res = intuition[-588](d1,a0,a1).  The second Permit
**	has no matching Forbid -- TDNestCnt goes negative
**	(shipped bug, preserved).
*/
LONG RARequest(LONG d1v __asm("d1"), APTR a0v __asm("a0"),
	       APTR a1v __asm("a1"))
{
    LONG res = -3;
    struct SignalSemaphore *ss;
    struct MsgPort *port;

    EXEC_CALL(132);				/* Forbid	    */
    ss = EXEC_CALL1R(594, s_semname);		/* FindSemaphore    */
    if (ss) {
	if (EXEC_CALL1B(720, ss)) {		/* AttemptShared    */
	    EXEC_CALL(138);			/* Permit	    */
	    port = (struct MsgPort *)EXEC_CALL1L(390, s_portname);
	    if (port) {
		ra_warpcore = *(ULONG **)((UBYTE *)port + 46);
		res = WC_CALL(30, d1v, a0v, a1v);
	    }
	    EXEC_CALL1(570, ss);		/* ReleaseSemaphore */
	}
    }
    EXEC_CALL(138);				/* Permit (2nd!)    */

    if (res == -3)
	res = INTUI_CALL(588, d1v, a0v, a1v);	/* EasyRequestArgs */

    return res;
}

/*
**	-36 RABuildRequest -- proxy for intuition's
**	BuildEasyRequestArgs (-594).  Same shape, four
**	register args (d0/d1/a0/a1).
*/
LONG RABuildRequest(LONG d0v __asm("d0"), LONG d1v __asm("d1"),
		    APTR a0v __asm("a0"), APTR a1v __asm("a1"))
{
    LONG res = -3;
    LONG saved0 = d0v;
    struct SignalSemaphore *ss;
    struct MsgPort *port;

    EXEC_CALL(132);				/* Forbid	    */
    ss = EXEC_CALL1R(594, s_semname);		/* FindSemaphore    */
    if (ss) {
	if (EXEC_CALL1B(720, ss)) {		/* AttemptShared    */
	    EXEC_CALL(138);			/* Permit	    */
	    port = (struct MsgPort *)EXEC_CALL1L(390, s_portname);
	    if (port) {
		ra_warpcore = *(ULONG **)((UBYTE *)port + 46);
		{
		    register void * __p_wc __asm("a6") = ra_warpcore;
		    register LONG  __p_d0 __asm("d0") = saved0;
		    register LONG  __p_d1 __asm("d1") = d1v;
		    register APTR  __p_a0 __asm("a0") = a0v;
		    register APTR  __p_a1 __asm("a1") = a1v;
		    register LONG  __p_res __asm("d0");
		    __asm volatile ("jsr %/a6@(-36:W)\n"
			: "=r"(__p_res)
			: "r"(__p_d1), "a"(__p_a0), "a"(__p_a1),
			  "a"(__p_wc), "0"(__p_d0)
			: "cc", "memory", "d2", "d3", "a2", "a3" );
		    res = __p_res;
		}
	    }
	    EXEC_CALL1(570, ss);		/* ReleaseSemaphore */
	}
    }
    EXEC_CALL(138);				/* Permit (2nd!)    */

    if (res == -3) {
	register void * __p_ib __asm("a6") = ra_intuition;
	register LONG  __p_d0 __asm("d0") = saved0;
	register LONG  __p_d1 __asm("d1") = d1v;
	register APTR  __p_a0 __asm("a0") = a0v;
	register APTR  __p_a1 __asm("a1") = a1v;
	register LONG  __p_res __asm("d0");
	__asm volatile ("jsr %/a6@(-594:W)\n"
	    : "=r"(__p_res)
	    : "r"(__p_d1), "a"(__p_a0), "a"(__p_a1),
	      "a"(__p_ib), "0"(__p_d0)
	    : "cc", "memory", "d2", "d3", "a2", "a3" );
	res = __p_res;
    }

    return res;
}
