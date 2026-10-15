/*
**	ghostrider.c -- GhostRider.library 37.2 (3 Aug 1994)
**
**	C reconstruction of the shipped binary.
**
**	GhostRider is a hotkey input-event interceptor.  GRArm()
**	(d0 != 0) installs a struct Interrupt input handler at
**	priority 64 via input.device IND_ADDHANDLER (io_Command 9);
**	d0 == 0 removes it with IND_REMHANDLER (10).
**
**	The handler walks the event chain and consumes every event
**	(it returns NULL).  On a matching trigger it pokes INTREQ,
**	invokes launcher function #0, and swallows the key event:
**	  - IECLASS_RAWKEY (1), armed by mode bit3: ie_Code low byte
**	    == keycode AND (ie_Qualifier & ~CAPSLOCK) == qual mask;
**	  - IECLASS_RAWMOUSE (2): (ie_Qualifier>>12)&7 == mode byte
**	    (the button field MID/R/LEFT at bits 12-14).
**
**	Launcher functions live in a private {UWORD key, LONG (*fn)()}
**	table reached through FindPort("GhostRider.Port") -> port+0x22
**	(a field the launcher overloads one longword past a normal
**	MsgPort).  GRDispatch (-30) always invokes table key 0;
**	GRCall6 (-42)/GRCall7 (-48) invoke keys 6/7 wrapped in
**	Disable, a 68010+ VBR write (movec d4,vbr — d4 is whatever
**	the caller left in it, see okf/findings), CacheClearU and
**	Enable.
*/

#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/libraries.h>
#include <exec/execbase.h>
#include <exec/interrupts.h>
#include <exec/ports.h>
#include <exec/io.h>
#include <devices/inputevent.h>
#include <dos/dos.h>		/* BPTR */

#define INTREQ (*(volatile UWORD *)0xdff09a)

/* ------------------------------------------------------------------ */
/* private structures						  */
/* ------------------------------------------------------------------ */

struct GRBase			/* InitTable dataSize = 0x2a	   */
{
    struct Library gr_Lib;	/* 0x00 standard library node (34 b.)  */
    BPTR  gr_SegList;		/* 0x22 seglist, stored by LibInit	   */
    struct ExecBase *gr_Sys;	/* 0x26 SysBase, stored by LibInit	   */
};

/* launcher function table entry: { UWORD key; LONG (*fn)(); } */

struct GRState			/* embedded state block (a5 in orig) */
{
    UBYTE  pad0[4];		/* +0x00				   */
    UBYTE  installed;		/* +0x04				   */
    UBYTE  pad5;		/* +0x05				   */
    struct Interrupt intr;	/* +0x06 input handler node		   */
    struct IOStdReq ioreq;	/* +0x1c input.device request		   */
    struct MsgPort port;	/* +0x4c reply port			   */
    UWORD  qual;		/* +0x6e qualifier mask (d2)		   */
    UBYTE  keycode;		/* +0x70 ie_Code low byte (d1)	   */
    UBYTE  mode;		/* +0x71 trigger mode (d0)		   */
    UBYTE  pad72[6];		/* tail pad				   */
};

extern struct GRState grstate;
extern const char s_portname[];		/* "GhostRider.Port"	   */
extern const char s_launcher[];		/* "Setup GhostRider Launcher" */
extern const char s_inputdev[];		/* "input.device"	   */

/* asm helper (ghostrider_lib.s): if AFF_68010, Supervisor(movec d4,vbr) */
void GRSupervisor(struct ExecBase *sys __asm("a6"));

struct InputEvent *GRInputHandler(struct InputEvent *ev __asm("a0"));

/* ------------------------------------------------------------------ */
/* Exec LVO calls							  */
/* ------------------------------------------------------------------ */

#define __Remove(__sys, ___node) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_node __asm("a1") = (void *)(___node);\
  __asm volatile (\
		   "jsr %/a6@(-252:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_node), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __FreeMem(__sys, ___blk, ___size) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_blk __asm("a1") = (void *)(___blk);\
  register ULONG __p_size __asm("d0") = (ULONG)(___size);\
  __asm volatile (\
		   "jsr %/a6@(-210:W)\n"\
		   : /* no outputs */\
		   : "a"(__p_blk), "d"(__p_size), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );})

#define __Disable(__sys) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  __asm volatile ("jsr %/a6@(-120:W)\n"\
		   : : "a"(__p_sys) : "cc", "memory", "d0", "d1", "a0", "a1" );})

#define __Enable(__sys) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  __asm volatile ("jsr %/a6@(-126:W)\n"\
		   : : "a"(__p_sys) : "cc", "memory", "d0", "d1", "a0", "a1" );})

#define __CacheClearU(__sys) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  __asm volatile ("jsr %/a6@(-636:W)\n"\
		   : : "a"(__p_sys) : "cc", "memory", "d0", "d1", "a0", "a1" );})

#define __FindPort(__sys, ___name) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register const char * __p_name __asm("a1") = (const char *)(___name);\
  register void * __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-390:W)\n"\
		   : "=r"(__p_res)\
		   : "a"(__p_name), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );\
  __p_res;})

#define __FindTask(__sys, ___name) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_name __asm("a1") = (void *)(___name);\
  register void * __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-294:W)\n"\
		   : "=r"(__p_res)\
		   : "a"(__p_name), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );\
  __p_res;})

#define __AddPort(__sys, ___port) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_port __asm("a1") = (void *)(___port);\
  __asm volatile ("jsr %/a6@(-354:W)\n"\
		   : : "a"(__p_port), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __RemPort(__sys, ___port) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_port __asm("a1") = (void *)(___port);\
  __asm volatile ("jsr %/a6@(-360:W)\n"\
		   : : "a"(__p_port), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __OpenDevice(__sys, ___name, ___unit, ___req, ___flags) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register const char * __p_name __asm("a0") = (const char *)(___name);\
  register ULONG __p_unit __asm("d0") = (ULONG)(___unit);\
  register void * __p_req __asm("a1") = (void *)(___req);\
  register ULONG __p_flags __asm("d1") = (ULONG)(___flags);\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-444:W)\n"\
		   : "=r"(__p_res)\
		   : "a"(__p_name), "d"(__p_unit), "a"(__p_req), "d"(__p_flags), "a"(__p_sys)\
		   : "cc", "memory" );\
  __p_res;})

#define __CloseDevice(__sys, ___req) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_req __asm("a1") = (void *)(___req);\
  __asm volatile ("jsr %/a6@(-450:W)\n"\
		   : : "a"(__p_req), "a"(__p_sys)\
		   : "cc", "memory", "d0", "d1", "a0" );})

#define __DoIO(__sys, ___req) ({\
  register void * __p_sys __asm("a6") = (void *)(__sys);\
  register void * __p_req __asm("a1") = (void *)(___req);\
  register LONG __p_res __asm("d0");\
  __asm volatile ("jsr %/a6@(-456:W)\n"\
		   : "=r"(__p_res)\
		   : "a"(__p_req), "a"(__p_sys)\
		   : "cc", "memory", "d1", "a0" );\
  __p_res;})

#define SYSBASE	(*(struct ExecBase **)4)

/* ------------------------------------------------------------------ */
/* standard library vectors						  */
/* ------------------------------------------------------------------ */

struct Library *LibInit(struct GRBase *base __asm("d0"),
			BPTR seglist __asm("a0"),
			struct ExecBase *sys __asm("a6"))
{
    base->gr_SegList = seglist;
    base->gr_Sys     = sys;

    return (struct Library *)base;
}

struct Library *LibOpen(struct GRBase *base __asm("a6"))
{
    base->gr_Lib.lib_OpenCnt++;
    base->gr_Lib.lib_Flags &= ~LIBF_DELEXP;

    return (struct Library *)base;
}

BPTR LibExpunge(struct GRBase *base __asm("a6"));

BPTR LibExpunge(struct GRBase *base __asm("a6"))
{
    struct ExecBase *sys = SYSBASE;
    BPTR   seg;

    if (base->gr_Lib.lib_OpenCnt) {
	base->gr_Lib.lib_Flags |= LIBF_DELEXP;
	return 0;
    }

    seg = base->gr_SegList;
    __Remove(sys, &base->gr_Lib.lib_Node);
    __FreeMem(sys, (UBYTE *)base - base->gr_Lib.lib_NegSize,
	      (ULONG)base->gr_Lib.lib_NegSize + base->gr_Lib.lib_PosSize);

    return seg;
}

/* Quirk: the shipped Close never expunges -- when the count hits
** zero and LIBF_DELEXP is set it simply returns 0. */
LONG LibClose(struct GRBase *base __asm("a6"))
{
    --base->gr_Lib.lib_OpenCnt;

    return 0;
}

/* LibNull (LVO -24 reserved) */
LONG LibNull(void)
{
    return 0;
}

/* ------------------------------------------------------------------ */
/* launcher function-table lookup					  */
/* ------------------------------------------------------------------ */

/* original helper at hunk+0x100: FindPort("GhostRider.Port"), then
** scan { UWORD key; LONG (*fn)(); } entries at port+0x22 until a
** negative key.  Returns 0 and the fn pointer, or -2. */
static LONG gr_findfn(UWORD id, LONG (**fn)(void))
{
    struct ExecBase *sys = SYSBASE;
    struct MsgPort *port;
    UWORD *tab;

    port = (struct MsgPort *)__FindPort(sys, s_portname);
    if (!port)
	return -2;

    tab = *(UWORD **)((UBYTE *)port + 0x22);
    while ((SHORT)tab[0] >= 0) {
	if (tab[0] == id) {
	    *fn = (LONG (*)(void))*(ULONG *)(tab + 1);
	    return 0;
	}
	tab += 3;
    }

    return -2;
}

/* ------------------------------------------------------------------ */
/* public vectors							  */
/* ------------------------------------------------------------------ */

/*
**	GRDispatch (LVO -30)
**
**	Invokes launcher table key 0 with d0 = arg; the handler's
**	return values are discarded (all registers are restored),
**	so the vector returns its argument.
*/
LONG GRDispatch(LONG arg __asm("d0"))
{
    LONG (*fn)(void);

    if (gr_findfn(0, &fn) == 0)
	((LONG (*)(LONG))fn)(arg);	/* handler gets the arg in d0 */

    return arg;
}

/*
**	GRArm (LVO -36)
**
**	d0 == 0: remove the handler (IND_REMHANDLER).
**	else:    store trigger mode (d0 byte), keycode (d1 byte) and
**	    qualifier mask (d2 word), then install the handler.
**	Returns 0 (or the request result, ignored by the original).
*/
static LONG gr_openio(void)
{
    struct ExecBase *sys = SYSBASE;
    struct MsgPort *port;
    struct Task *self;

    /* the original tests the OpenDevice return value (d0), not
    ** io_Device -- nonzero means failure and is returned */
    if (__OpenDevice(sys, s_inputdev, 0, &grstate.ioreq, 0))
	return -1;

    self = (struct Task *)__FindTask(sys, NULL);
    port = &grstate.port;
    port->mp_Node.ln_Type = NT_MSGPORT;
    port->mp_Node.ln_Pri = -1;	/* 'st' in the original */
    port->mp_Flags = PA_SIGNAL;
    port->mp_SigTask = self;
    port->mp_Node.ln_Name = (char *)s_launcher;
    __AddPort(sys, port);

    return 0;
}

static void gr_closeio(void)
{
    struct ExecBase *sys = SYSBASE;

    __CloseDevice(sys, &grstate.ioreq);
    __RemPort(sys, &grstate.port);
}

LONG GRArm(UWORD mode __asm("d0"), UBYTE keycode __asm("d1"),
	   UWORD qual __asm("d2"))
{
    struct ExecBase *sys = SYSBASE;

    if (!mode) {
	if (!grstate.installed)
	    return 0;
	if (gr_openio())
	    return 0;
	grstate.ioreq.io_Message.mn_ReplyPort = &grstate.port;
	grstate.ioreq.io_Data = &grstate.intr;
	grstate.ioreq.io_Command = 10;	/* IND_REMHANDLER */
	(void)__DoIO(sys, &grstate.ioreq);
	gr_closeio();
	grstate.installed = 0;
	return 0;
    }

    grstate.mode = (UBYTE)mode;
    grstate.keycode = keycode;
    grstate.qual = qual;

    if (grstate.installed)
	return 0;
    if (gr_openio())
	return 0;

    grstate.ioreq.io_Message.mn_Node.ln_Type = NT_MESSAGE;
    grstate.ioreq.io_Message.mn_ReplyPort = &grstate.port;
    grstate.ioreq.io_Data = &grstate.intr;
    /* the original writes a literal 973 (0x3cd) into ln_Name --
    ** an unrelocated pointer bug, reproduced faithfully */
    grstate.intr.is_Node.ln_Pri = 64;
    grstate.intr.is_Node.ln_Name = (char *)973;
    grstate.intr.is_Data = NULL;
    grstate.intr.is_Code = (void (*)())GRInputHandler;
    grstate.ioreq.io_Command = 9;		/* IND_ADDHANDLER */
    (void)__DoIO(sys, &grstate.ioreq);
    grstate.installed = 1;

    return 0;
}

/*
**	GRCall6 / GRCall7 (LVO -42 / -48)
**
**	Invoke launcher table keys 6 and 7 with the arg in a0,
**	wrapped in Disable / VBR-supervisor-thunk / CacheClearU /
**	Enable.  Return -2 when the launcher or the key is absent,
**	else the handler's d0 (GRCall7 also preserves its d1).
*/
LONG GRCall6(APTR arg __asm("a0"))
{
    struct ExecBase *sys = SYSBASE;
    LONG (*fn)(void);
    LONG res;

    if (gr_findfn(6, &fn))
	return -2;

    __Disable(sys);
    GRSupervisor(sys);
    res = ((LONG (*)(APTR))fn)(arg);
    __CacheClearU(sys);
    __Enable(sys);

    return res;
}

LONG GRCall7(APTR arg __asm("a0"))
{
    struct ExecBase *sys = SYSBASE;
    LONG (*fn)(void);
    register LONG rd1 __asm("d1");
    LONG res;

    if (gr_findfn(7, &fn))
	return -2;

    __Disable(sys);
    GRSupervisor(sys);
    res = ((LONG (*)(APTR))fn)(arg);
    __asm volatile("" : "+r"(rd1));	/* capture handler's d1 */
    __CacheClearU(sys);
    __Enable(sys);

    return res;
}

/* ------------------------------------------------------------------ */
/* input handler (is_Code, original at hunk+0x2ba)			  */
/* ------------------------------------------------------------------ */

struct InputEvent *GRInputHandler(struct InputEvent *ev __asm("a0"))
{
    UBYTE mode = grstate.mode;
    UBYTE keycode = grstate.keycode;
    UWORD qual = grstate.qual;
    LONG (*fn)(void);

    for (;;) {
	if (ev->ie_Class == IECLASS_RAWKEY) {
	    if ((mode & 8) &&
		((UBYTE *)&ev->ie_Code)[1] == keycode &&
		(ev->ie_Qualifier & 0xfb) == qual) {
		INTREQ = 8;
		if (gr_findfn(0, &fn) == 0)
		    ((LONG (*)(LONG))fn)(0);
		INTREQ = 0x8008;
		ev->ie_Class = 0;
	    }
	} else if (ev->ie_Class == IECLASS_RAWMOUSE) {
	    if (((ev->ie_Qualifier >> 12) & 7) == mode) {
		if (gr_findfn(0, &fn) == 0)
		    ((LONG (*)(LONG))fn)(0);
	    }
	}
	ev = ev->ie_NextEvent;
	if (!ev)
	    break;
    }

    return ev;			/* NULL -- consumes the chain */
}
