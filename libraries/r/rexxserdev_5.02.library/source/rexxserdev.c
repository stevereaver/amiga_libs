/* rexxserdev.library 5.02 — C reconstruction
 *
 * ARexx function library: registers 14 Ser* functions, dispatched
 * through the single public vector (-30).  Each call arrives with
 * a6 = library base, a0 = request block; the dispatcher resolves
 * the handle argument to a SerObj (a2) via a rexxsyslib internal.
 *
 * Private library data (posSize = 0x42 = 66):
 *   +34 ExecBase    +38 RexxSysBase   +42 UtilityBase  +46 SegList
 *   +50 open-object count (long)      +54 MinList of SerObjs
 *
 * SerObj (60 bytes):
 *   +0/+4  MinNode succ/pred          +8  read port's mp_SigTask
 *   +12    current request block      +16 read  IOExtSer (82B)
 *   +20    read  MsgPort              +24 write IOExtSer
 *   +28    write MsgPort              +32 ctrl  IOExtSer
 *   +36    ctrl  MsgPort              +40 reply scratch buffer
 */

typedef unsigned char  UBYTE;
typedef unsigned short UWORD;
typedef unsigned long  ULONG;
typedef long           LONG;
typedef void          *APTR;
typedef char          *STRPTR;

/* register bindings supplied by the asm dispatcher */
register char *g_obj  __asm("a2");	/* SerObj    */
register char *g_base __asm("a5");	/* lib base  */
register char *g_msg  __asm("d4");	/* request   */

/* reply delivery: C returns error code in d0, reply ptr via g_result */
ULONG g_result;

#define SYS	(*(APTR*)(g_base+34))
#define RXS	(*(APTR*)(g_base+38))
#define OBJ	((struct SerObj*)g_obj)

struct SerObj {
	APTR succ, pred, sigtask, msg;
	APTR io1, port1, io2, port2, io3, port3;
	char buf[20];
};

/* IOExtSer field offsets (82-byte block) */
#define IO_TYPE		8
#define IO_REPLY	14
#define IO_MN_LEN	18
#define IO_DEVICE	20
#define IO_UNIT		24
#define IO_COMMAND	28
#define IO_FLAGS	30
#define IO_ACTUAL	32
#define IO_LENGTH	36
#define IO_DATA		40
#define IO_CTLCHAR	48
#define IO_RBUFLEN	52
#define IO_EXTFLAGS	56
#define IO_BAUD		60
#define IO_BRKTIME	64
#define IO_READLEN	76
#define IO_WRITELEN	77
#define IO_STOPBITS	78
#define IO_SERFLAGS	79
#define IO_STATUS	80

#define F8(o,f)		(*(UBYTE*)((char*)(o)+(f)))
#define F16(o,f)	(*(UWORD*)((char*)(o)+(f)))
#define F32(o,f)	(*(ULONG*)((char*)(o)+(f)))

/* symbols from the asm skeleton */
extern char idstr[];
extern char rep_ok[];	/* "1" */
extern char rep_err[];	/* "0" */

/*------------------------- LVO call stubs ------------------------*/
static inline APTR _AllocMem(ULONG sz, ULONG fl, APTR sys)
{	register APTR r __asm("d0"); register ULONG a0 __asm("d0") = sz;
	register ULONG a1 __asm("d1") = fl; register APTR a6 __asm("a6") = sys;
	__asm volatile("jsr a6@(-198)" : "=r"(r)
		: "r"(a0),"r"(a1),"r"(a6) : "memory","cc");
	return r; }
static inline void _FreeMem(APTR blk, ULONG sz, APTR sys)
{	register APTR a1 __asm("a1") = blk; register ULONG a0 __asm("d0") = sz;
	register APTR a6 __asm("a6") = sys;
	__asm volatile("jsr a6@(-210)" :: "r"(a1),"r"(a0),"r"(a6)
		: "memory","cc"); }
static inline APTR _CreateMsgPort(APTR sys)
{	register APTR r __asm("d0"); register APTR a6 __asm("a6") = sys;
	__asm volatile("jsr a6@(-666)" : "=r"(r) : "r"(a6)
		: "memory","cc");
	return r; }
static inline void _DeleteMsgPort(APTR p, APTR sys)
{	register APTR a0 __asm("a0") = p; register APTR a6 __asm("a6") = sys;
	__asm volatile("jsr a6@(-672)" :: "r"(a0),"r"(a6)
		: "memory","cc"); }
static inline LONG _OpenDevice(APTR name, ULONG unit, APTR io, ULONG fl, APTR sys)
{	register LONG r __asm("d0"); register APTR a0 __asm("a0") = name;
	register ULONG a2 __asm("d0") = unit; register APTR a1 __asm("a1") = io;
	register ULONG a3 __asm("d1") = fl; register APTR a6 __asm("a6") = sys;
	__asm volatile("jsr a6@(-444)" : "=r"(r)
		: "r"(a0),"r"(a2),"r"(a1),"r"(a3),"r"(a6)
		: "memory","cc");
	return r; }
static inline void _CloseDevice(APTR io, APTR sys)
{	register APTR a1 __asm("a1") = io; register APTR a6 __asm("a6") = sys;
	__asm volatile("jsr a6@(-450)" :: "r"(a1),"r"(a6)
		: "memory","cc"); }
static inline LONG _DoIO(APTR io, APTR sys)
{	register LONG r __asm("d0"); register APTR a1 __asm("a1") = io;
	register APTR a6 __asm("a6") = sys;
	__asm volatile("jsr a6@(-456)" : "=r"(r) : "r"(a1),"r"(a6)
		: "memory","cc");
	return r; }

/* rexxsyslib internals (undocumented vectors) */
static inline APTR _RxsCreateArgstring(APTR s, ULONG len, APTR rxs)
{	register APTR r __asm("a0"); register APTR a0 __asm("a0") = s;
	register ULONG a1 __asm("d0") = len; register APTR a6 __asm("a6") = rxs;
	__asm volatile("jsr a6@(-126)" : "=r"(r)
		: "r"(a0),"r"(a1),"r"(a6) : "memory","cc");
	return r; }
static inline ULONG _RxsStrlen(APTR s, APTR rxs)	/* -288: str -> len */
{	register ULONG r __asm("d0"); register APTR a0 __asm("a0") = s;
	register APTR a6 __asm("a6") = rxs;
	__asm volatile("jsr a6@(-288)" : "=r"(r) : "r"(a0),"r"(a6)
		: "memory","cc");
	return r; }
static inline ULONG _RxsArgVal(APTR arg, APTR rxs) /* -300: argstring -> long */
{	register ULONG r __asm("d0"); register APTR a0 __asm("a0") = arg;
	register APTR a6 __asm("a6") = rxs;
	__asm volatile("jsr a6@(-300)" : "=r"(r) : "r"(a0),"r"(a6)
		: "memory","cc");
	return r; }
static inline LONG _RxsFmt(char *dst, ULONG val, ULONG w, APTR rxs)
					/* -306: long -> decimal into dst */
{	register LONG r __asm("d0"); register char *a0 __asm("a0") = dst;
	register ULONG a2 __asm("d0") = val; register ULONG a3 __asm("d1") = w;
	register APTR a6 __asm("a6") = rxs;
	__asm volatile("jsr a6@(-306)" : "=r"(r)
		: "r"(a0),"r"(a2),"r"(a3),"r"(a6)
		: "memory","cc");
	return r; }
static inline APTR _RxsValStr(ULONG v, APTR rxs)	/* -312: long -> argstring */
{	register APTR r __asm("a0"); register ULONG a0 __asm("d0") = v;
	register APTR a6 __asm("a6") = rxs;
	__asm volatile("jsr a6@(-312)" : "=r"(r) : "r"(a0),"r"(a6)
		: "memory","cc");
	return r; }

/*------------------------- block helpers ------------------------*/
/* 0x1aa: allocate IOExtSer — ln_Type 5, mn_Length=size, mn_ReplyPort=port */
static APTR alloc_io(ULONG size, APTR port)
{
	APTR io = _AllocMem(size, 0x10001, SYS);
	if (io) {
		F8(io,IO_TYPE)	= 5;
		F16(io,IO_MN_LEN) = (UWORD)size;
		F32(io,IO_REPLY) = (ULONG)port;
	}
	return io;
}

/* 0x1e6: release IOExtSer — type/device/unit := -1, free mn_Length bytes.
 * DEFECT: FreeMem size comes from a bare move.w -> the high 16 bits of
 * d0 keep the caller's residue, so FreeMem can get a hugely inflated
 * size.  (This is the bug the Aminet RexxSerDevFix patch addresses.) */
static void free_io(APTR io)
{
	ULONG sz;
	__asm volatile("movel %%d0,%0" : "=r"(sz));
	if (!io) return;
	F8(io,IO_TYPE) = 0xff;
	F32(io,IO_DEVICE) = ~0;
	F32(io,IO_UNIT) = ~0;
	sz = (sz & 0xffff0000) | F16(io,IO_MN_LEN);
	_FreeMem(io, sz, SYS);
}

/* 0x282: close + free read channel */
static void free_chan1(void)
{
	_CloseDevice(OBJ->io1, SYS);
	free_io(OBJ->io1);
	_DeleteMsgPort(OBJ->port1, SYS);
}
/* 0x2e4: free write channel */
static void free_chan2(void)
{	free_io(OBJ->io2); _DeleteMsgPort(OBJ->port2, SYS); }
/* 0x33a: free ctrl channel */
static void free_chan3(void)
{	free_io(OBJ->io3); _DeleteMsgPort(OBJ->port3, SYS); }

/* 0x68c: allocate 60-byte object, AddHead into lib MinList@54 */
static APTR alloc_obj(void)
{
	APTR o = _AllocMem(60, 0x10001, SYS);
	if (o) {
		char *head = g_base + 54;
		ULONG old = F32(head,0);
		F32(head,0) = (ULONG)o;
		F32(o,0) = old;
		F32(o,4) = (ULONG)head;
		F32(old,4) = (ULONG)o;
	}
	return o;
}

/* 0x6d8: unlink + free object */
static void free_obj(void)
{
	char *o = g_obj;
	ULONG s = F32(o,0), p = F32(o,4);
	F32(p,0) = s; F32(s,4) = p;
	_FreeMem(o, 60, SYS);
}

/* 0x212: read channel — port, io, OpenDevice(devname,unit,io,0) */
static long open_chan1(void)
{
	APTR port = _CreateMsgPort(SYS);
	OBJ->port1 = port;
	if (!port) return 3;
	OBJ->sigtask = (APTR)F32(port,16);	/* mp_SigTask */
	APTR io = alloc_io(82, port);
	OBJ->io1 = io;
	if (!io) { _DeleteMsgPort(port, SYS); return 3; }
	ULONG unit = _RxsArgVal(*(APTR*)(g_msg+48), RXS);
	F16(io,IO_COMMAND) = 0;
	F8(io,IO_SERFLAGS) = 32;
	if (_OpenDevice(*(APTR*)(g_msg+44), unit, io, 0, SYS)) {
		free_io(io); _DeleteMsgPort(port, SYS); return 12;
	}
	return 0;
}

/* 0x2a0: write channel — shares io1's device/unit */
static long open_chan2(void)
{
	APTR port = _CreateMsgPort(SYS);
	OBJ->port2 = port;
	if (!port) return 3;
	APTR io = alloc_io(82, port);
	OBJ->io2 = io;
	if (!io) { _DeleteMsgPort(port, SYS); return 3; }
	F32(io,IO_DEVICE) = F32(OBJ->io1,IO_DEVICE);
	F32(io,IO_UNIT)   = F32(OBJ->io1,IO_UNIT);
	return 0;
}

/* 0x2f6: ctrl channel — same device/unit share */
static long open_chan3(void)
{
	APTR port = _CreateMsgPort(SYS);
	OBJ->port3 = port;
	if (!port) return 3;
	APTR io = alloc_io(82, port);
	OBJ->io3 = io;
	if (!io) { _DeleteMsgPort(port, SYS); return 3; }
	F32(io,IO_DEVICE) = F32(OBJ->io1,IO_DEVICE);
	F32(io,IO_UNIT)   = F32(OBJ->io1,IO_UNIT);
	return 0;
}

/*---------------------------- replies ---------------------------*/
static long reply(APTR s)
{	g_result = (ULONG)_RxsCreateArgstring(s, 1, RXS); return 0; }

/*--------------------------- commands ---------------------------*/
static long simple_cmd(UWORD cmd, APTR io)	/* -> "1"/"0" */
{
	F16(io,IO_COMMAND) = cmd;
	F8(io,IO_FLAGS) = 0;
	return reply(_DoIO(io, SYS) ? rep_err : rep_ok);
}

/* idx0 SerQuery @0x4b4: SDCMD_QUERY -> "1 <actual> <status>" / "0" */
long SerQuery(void)
{
	char *io = OBJ->io3;
	F16(io,IO_COMMAND) = 9;
	F8(io,IO_FLAGS) = 0;
	if (_DoIO(io, SYS)) return reply(rep_err);
	char *b = OBJ->buf;
	F16(b,0) = 0x3120;				/* "1 " */
	LONG n = _RxsFmt(b+2, F32(io,IO_ACTUAL), 12, RXS);
	b[2+n] = ' ';
	n += 3;
	n += _RxsFmt(b+n, F16(io,IO_STATUS), 8, RXS);
	g_result = (ULONG)_RxsCreateArgstring(b, n, RXS);
	return 0;
}

/* idx1 SerRead @0x3b6: CMD_READ -> data argstring / "##ERROR=e" */
long SerRead(void)
{
	char *io = OBJ->io1;
	F32(io,IO_DATA)   = _RxsArgVal(*(APTR*)(g_msg+48), RXS);
	F32(io,IO_LENGTH) = _RxsArgVal(*(APTR*)(g_msg+52), RXS);
	F16(io,IO_COMMAND) = 2;
	F8(io,IO_FLAGS) = 0;
	LONG e = _DoIO(io, SYS);
	if (e) {
		char *b = OBJ->buf;
		*(ULONG*)b     = 0x23234552;	/* "##ER" */
		*(ULONG*)(b+4) = 0x524f523d;	/* "ROR=" */
		LONG n = _RxsFmt(b+8, e, 12, RXS) + 8;
		g_result = (ULONG)_RxsCreateArgstring(b, n, RXS);
	} else
		g_result = (ULONG)_RxsCreateArgstring(
			(APTR)F32(io,IO_DATA), F32(io,IO_ACTUAL), RXS);
	return 0;
}

/* idx2 SerWrite @0x456: CMD_WRITE -> "1"/"0" */
long SerWrite(void)
{
	char *io = OBJ->io2;
	F32(io,IO_DATA)   = (ULONG)*(APTR*)(g_msg+48);
	F32(io,IO_LENGTH) = _RxsArgVal(*(APTR*)(g_msg+52), RXS);
	F16(io,IO_COMMAND) = 3;
	F8(io,IO_FLAGS) = 0;
	return reply(_DoIO(io, SYS) ? rep_err : rep_ok);
}

/* idx3 SerSetParms @0x530: SDCMD_SETPARAMS -> "1"/"0" */
long SerSetParms(void)
{
	char *io = OBJ->io3;
	F32(io,IO_BAUD)    = _RxsArgVal(*(APTR*)(g_msg+48), RXS);
	ULONG v = _RxsArgVal(*(APTR*)(g_msg+52), RXS);
	F8(io,IO_READLEN)  = (UBYTE)v;
	F8(io,IO_WRITELEN) = (UBYTE)v;
	F8(io,IO_STOPBITS) = (UBYTE)_RxsArgVal(*(APTR*)(g_msg+60), RXS);
	F32(io,IO_EXTFLAGS) = 0;
	ULONG d0 = 32;
	char *p = *(char**)(g_msg+56);
	if (*p != 'N') {
		d0 |= 1;
		if (*p != 'E') {
			if (*p == 'O') d0 |= 2;
			else {
				F32(io,IO_EXTFLAGS) |= 2;
				if (*p != 'S') F32(io,IO_EXTFLAGS) |= 1;
			}
		}
	}
	p = *(char**)(g_msg+64);
	if (p && *p == '0') d0 |= 0x80;
	F8(io,IO_SERFLAGS) = (UBYTE)d0;
	p = *(char**)(g_msg+72);
	ULONG rb = p ? _RxsArgVal(p, RXS) : 0;
	F32(io,IO_RBUFLEN) = rb ? rb : 1024;
	F16(io,IO_COMMAND) = 11;
	F8(io,IO_FLAGS) = 0;
	F32(io,IO_CTLCHAR) = 0x11130000;
	F32(io,IO_BRKTIME) = 250000;
	return reply(_DoIO(io, SYS) ? rep_err : rep_ok);
}

/* idx4 SerClear @0x34c: CMD_CLEAR on ctrl io */
long SerClear(void)	{ return simple_cmd(5, OBJ->io3); }

/* idx5 SerFlush @0x36e: CMD_FLUSH on read or write io
 * DEFECT: `d0|0x60` is compared against 'R'/'W' — the OR always sets
 * bit5, which both targets lack, so no argument can ever match and
 * the function always returns "0". */
long SerFlush(void)
{
	char *a1 = *(char**)(g_msg+48);
	char *io;
	ULONG d0 = F8(a1,48) | 0x60;
	if (d0 == 'R')		io = OBJ->io1;
	else if (d0 == 'W')	io = OBJ->io2;
	else			return reply(rep_err);
	F16(io,IO_COMMAND) = 8;
	F8(io,IO_FLAGS) = 0;
	return reply(_DoIO(io, SYS) ? rep_err : rep_ok);
}

/* idx6 SerReset @0x430: CMD_RESET on ctrl io */
long SerReset(void)	{ return simple_cmd(1, OBJ->io3); }

/* idx7 SerBreak @0x496: SDCMD_BREAK on ctrl io */
long SerBreak(void)	{ return simple_cmd(10, OBJ->io3); }

/* idx8/9 SerStart/SerStop @0x452: stubs — always reply "0" */
long SerStart(void)	{ return reply(rep_err); }
long SerStop(void)	{ return reply(rep_err); }

/* idx10 SerClose @0x6bc: tear everything down, reply "1" */
long SerClose(void)
{
	F32(g_base,50) -= 1;
	free_chan3();	/* 0x6c6 chain: chan3 -> chan2 -> chan1 -> obj */
	free_chan2();
	free_chan1();
	free_obj();
	return reply(rep_ok);
}

/* idx11 SerOpen @0x632: build object + 3 channels, reply handle */
long SerOpen(void)
{
	APTR o = alloc_obj();
	long e;
	if (!o) return 3;
	g_obj = o;
	OBJ->msg = g_msg;
	if ((e = open_chan1())) { free_obj(); return e; }
	if ((e = open_chan2())) { free_chan1(); free_obj(); return e; }
	if ((e = open_chan3())) {
		free_chan2(); free_chan1(); free_obj(); return 3;
	}
	F32(g_base,50) += 1;
	g_result = (ULONG)_RxsValStr((ULONG)o, RXS);
	return 0;
}

/* idx12 SerLibBase @0x622: reply argstring(lib base) */
long SerLibBase(void)
{	g_result = (ULONG)_RxsValStr((ULONG)g_base, RXS); return 0; }

/* idx13 SerID @0x60c: reply argstring(id string) */
long SerID(void)
{
	g_result = (ULONG)_RxsCreateArgstring(
		(APTR)idstr, _RxsStrlen((APTR)idstr, RXS), RXS);
	return 0;
}
