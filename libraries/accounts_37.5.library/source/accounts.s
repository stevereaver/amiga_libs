/* accounts.library 37.5 (1.3.93) -- Commodore Envoy NIPC client library.
 * Single CODE hunk (0xa70 bytes). RomTag AUTOINIT, ver 37, NT_LIBRARY.
 * This is an RPC front-end: each public vector builds a request object
 * via nipc.library (tag 0x800b1101, request size), drops a command byte
 * ('j','k','l','m','n','o','p','q','t','u') at obj+28, and ships it to
 * the "Accounts Server" service located via nipc FindService-style call.
 *
 * InitTable @0x48: dsize=0xf4, functab@0x58 (word-offset form,
 *   leading -1 flag, offsets relative to table start, -1 terminated,
 *   19 vectors), datatab@0x82 (INITWORD lib_Revision=5), initfn@0x88.
 *
 * Library data layout (a6 = libbase in public entries):
 *   +0x16 lib_Revision = 5 (datatab)
 *   +0x22 (34)  NIPCBase
 *   +0x26 (38)  ExecBase
 *   +0x2a (42)  DOSBase
 *   +0x2e (46)  UtilityBase
 *   +0x32 (50)  seglist
 *   +0x36 (54)  nipc context (created via nipc -126)
 *   +0x3a (58)  nipc entity/service handle (nipc -138)
 *   +0x3e (62)  SignalSemaphore (46 bytes, InitSemaphore'd)
 *   +0x6c (108) magic 0xc0edbabe
 *   +0x70 (112) GetVar result code
 *   +0x74 (116) GetVar "Envoy/AccountsServer" buffer (128 bytes)
 */

	.globl	_RomTag,_initfn,_open,_close,_expunge,_nullvec
	.globl	_vec30,_vec36,_vec42,_vec48,_vec54,_vec60,_vec66
	.globl	_vec72,_vec78,_vec84,_vec90,_vec96,_vec102,_vec108,_vec114

	.text

/* ==== 0x0000 vestigial stub: return -1 =========================== */
_negone:
	moveq	#-1,%d0
	rts

/* ==== 0x0004 RomTag ============================================== */
_RomTag:
	.short	0x4afc
	.long	_RomTag			/* MatchTag  -> 0x04 */
	.long	_EndSkip		/* EndSkip   -> 0xa70 (end of hunk) */
	.byte	0x80,37			/* RTF_AUTOINIT, version 37 */
	.byte	9,0			/* NT_LIBRARY, pri 0 */
	.long	_libname
	.long	_idstr
	.long	_init

/* ==== 0x001e strings ============================================= */
_libname:
	.ascii	"accounts.library"
	.byte	0
_idstr:
	.ascii	"accounts 37.5 (1.3.93)\015\012"
	.byte	0

/* ==== 0x0048 InitTable (AUTOINIT) ================================ */
_init:
	.long	0xf4			/* dataSize */
	.long	_ftab			/* function table */
	.long	_dtab			/* InitStruct data */
	.long	_initfn			/* init routine */

/* ==== 0x0058 function table: -1 flag, word offsets rel to _ftab == */
_ftab:
	.short	-1
	.short	_open-_ftab		/* -6   Open                  */
	.short	_close-_ftab		/* -12  Close                 */
	.short	_expunge-_ftab		/* -18  Expunge               */
	.short	_nullvec-_ftab		/* -24  reserved              */
	.short	_vec30-_ftab		/* -30  alloc 40-byte object  */
	.short	_vec36-_ftab		/* -36  alloc 34-byte object  */
	.short	_vec42-_ftab		/* -42  free 40-byte object   */
	.short	_vec48-_ftab		/* -48  free 34-byte object   */
	.short	_vec54-_ftab		/* -54  'q' request           */
	.short	_vec60-_ftab		/* -60  't' request           */
	.short	_vec66-_ftab		/* -66  'n' request           */
	.short	_vec72-_ftab		/* -72  'p' request           */
	.short	_vec78-_ftab		/* -78  'm' request           */
	.short	_vec84-_ftab		/* -84  'o' request           */
	.short	_vec90-_ftab		/* -90  'j' request           */
	.short	_vec96-_ftab		/* -96  'l' request           */
	.short	_vec102-_ftab		/* -102 'k' request           */
	.short	_vec108-_ftab		/* -108 password hash         */
	.short	_vec114-_ftab		/* -114 'u' request           */
	.short	-1

/* ==== 0x0082 InitStruct data: lib_Revision = 5 ==================== */
_dtab:
	.byte	0x90,0x16		/* INITWORD, offset 22 (lib_Revision) */
	.short	5
	.byte	0,0			/* terminator + pad */

/* ==== 0x0088 initfn: d0=libbase, a0=seglist, a6=SysBase ============ */
_initfn:
	moveml	%a0/%a5,%sp@-
	moveal	%d0,%a5
	movel	%a6,%a5@(38)		/* ExecBase */
	movel	%a0,%a5@(50)		/* seglist */
	clrl	%a5@(34)		/* NIPCBase = 0 */
	clrl	%a5@(54)		/* context = 0 */
	clrl	%a5@(58)		/* entity = 0 */
	movel	#0xc0edbabe,%a5@(108)	/* magic */
	lea	%a5@(62),%a0
	jsr	%a6@(-558)		/* InitSemaphore(&lib+62) */
	moveq	#37,%d0
	lea	%pc@(_s_dos),%a1
	jsr	%a6@(-552)		/* OpenLibrary("dos.library",37) */
	movel	%d0,%a5@(42)		/* DOSBase */
	beqs	3f			/* failed -> return NULL */
	moveq	#37,%d0
	lea	%pc@(_s_util),%a1
	jsr	%a6@(-552)		/* OpenLibrary("utility.library",37) */
	movel	%d0,%a5@(46)		/* UtilityBase */
	bnes	2f
	moveal	%a5@(42),%a1
	jsr	%a6@(-414)		/* CloseLibrary(dos) on failure */
	moveq	#0,%d0
	bras	3f
2:	movel	%a5,%d0			/* success -> lib base */
3:	moveml	%sp@+,%a0/%a5
	rts

/* ==== 0x00e6 strings ============================================= */
_s_nipc:
	.ascii	"nipc.library"
	.byte	0
_s_util:
	.ascii	"utility.library"
	.byte	0
_s_accsrv:
	.ascii	"Accounts Server"
	.byte	0
_s_dos:
	.ascii	"dos.library"
	.byte	0
_s_envoy:
	.ascii	"Envoy/AccountsServer"
	.byte	0
_tagzero:
	.byte	0,0,0,0			/* empty taglist for nipc -126 */

/* ==== 0x0138 -6 Open ============================================= */
/* bumps OpenCnt; on first open: lock sema, open nipc.library, create
 * context, GetVar("Envoy/AccountsServer"), find "Accounts Server"
 * service; returns lib or 0 (opencnt rolled back on failure).      */
_open:
	addqw	#1,%a6@(32)		/* lib_OpenCnt++ */
	tstl	%a6@(58)		/* already have service entity? */
	bnew	6f			/* yes -> skip setup */
	lea	%a6@(62),%a0		/* &semaphore */
	movel	%a5,%sp@-
	moveal	%a6,%a5
	moveal	%a6@(38),%a6		/* ExecBase */
	jsr	%a6@(-564)		/* ObtainSemaphore */
	lea	%pc@(_s_nipc),%a1
	moveq	#0,%d0
	jsr	%a6@(-552)		/* OpenLibrary("nipc.library",0) */
	movel	%d0,%a5@(34)		/* NIPCBase */
	beqs	8f
	moveal	%d0,%a6
	lea	%pc@(_tagzero),%a0	/* empty taglist */
	jsr	%a6@(-126)		/* nipc create context */
	movel	%d0,%a5@(54)
	beqs	7f
	moveal	%a5@(42),%a6		/* DOSBase */
	lea	%pc@(_s_envoy),%a0	/* "Envoy/AccountsServer" */
	movel	%a0,%d1
	lea	%a5@(116),%a0		/* buffer */
	movel	%a0,%d2
	moveq	#127,%d3
	addql	#1,%d3			/* size = 128 */
	moveq	#0,%d4
	jsr	%a6@(-906)		/* dos GetVar -> lib+112 */
	movel	%d0,%a5@(112)
	bmis	4f			/* GVF_GLOBAL_ONLY? <0 -> a0=NULL */
	lea	%a5@(116),%a0		/* a0 = env value */
	bras	5f
4:	subal	%a0,%a0			/* a0 = NULL */
5:	lea	%pc@(_s_accsrv),%a1	/* "Accounts Server" */
	moveal	%a5@(54),%a2		/* context */
	moveal	%a5@(34),%a6		/* NIPCBase */
	jsr	%a6@(-138)		/* nipc find service */
	movel	%d0,%a5@(58)		/* entity */
	bnes	8f			/* got it -> finish */
	moveal	%a5@(54),%a0		/* failed: drop context */
	jsr	%a6@(-132)		/* nipc delete context */
7:	moveal	%a6,%a1			/* NIPCBase */
	moveal	%a5@(38),%a6		/* ExecBase */
	jsr	%a6@(-414)		/* CloseLibrary(nipc) */
8:	moveal	%a5@(38),%a6
	lea	%a5@(62),%a0
	jsr	%a6@(-570)		/* ReleaseSemaphore */
	moveal	%a5,%a6
	moveal	%sp@+,%a5
	tstl	%a6@(58)		/* entity set? */
	bnes	6f
	moveq	#0,%d0			/* no: undo open, fail */
	subqw	#1,%a6@(32)
	rts
6:	bclr	#3,%a6@(14)		/* clear LIBF_DELEXP */
	movel	%a6,%d0
	rts

/* ==== 0x01ec -12 Close ============================================ */
_close:
	subqw	#1,%a6@(32)		/* lib_OpenCnt-- */
	bnes	10f			/* still open -> 0 */
	movel	%a5,%sp@-
	moveal	%a6,%a5
	moveal	%a6@(38),%a6
	lea	%a5@(62),%a0
	jsr	%a6@(-564)		/* ObtainSemaphore */
	moveal	%a5@(34),%a6		/* NIPCBase */
	moveal	%a5@(58),%a0
	jsr	%a6@(-144)		/* nipc release entity */
	moveal	%a5@(54),%a0
	jsr	%a6@(-132)		/* nipc delete context */
	moveal	%a6,%a1
	moveal	%a5@(38),%a6
	jsr	%a6@(-414)		/* CloseLibrary(nipc) */
	lea	%a5@(62),%a0
	jsr	%a6@(-570)		/* ReleaseSemaphore */
	clrl	%a5@(34)
	clrl	%a5@(54)
	clrl	%a5@(58)
	moveal	%a5,%a6
	moveal	%sp@+,%a5
	btst	#3,%a6@(14)		/* LIBF_DELEXP? */
	bnes	9f			/* deferred expunge */
10:	moveq	#0,%d0
	rts

/* ==== 0x0244 -18 Expunge ========================================= */
_expunge:
	tstw	%a6@(32)		/* lib_OpenCnt */
	beqs	9f			/* zero -> expunge now */
	bset	#3,%a6@(14)		/* else set LIBF_DELEXP */
	moveq	#0,%d0
	rts

/* ==== 0x0254 shared expunge body (inline Remove + free) =========== */
9:	moveml	%d2/%a5-%a6,%sp@-
	moveal	%a6,%a5
	movel	%a5@(50),%d2		/* seglist */
	moveal	%a5,%a1
	moveal	%a1@+,%a0		/* ln_Succ */
	moveal	%a1@,%a1		/* ln_Pred */
	movel	%a0,%a1@		/* pred->succ = succ */
	movel	%a1,%a0@(4)		/* succ->pred = pred */
	moveal	%a5@(38),%a6		/* ExecBase */
	moveal	%a5@(46),%a1		/* UtilityBase */
	jsr	%a6@(-414)		/* CloseLibrary */
	moveal	%a5@(42),%a1		/* DOSBase */
	jsr	%a6@(-414)		/* CloseLibrary */
	moveal	%a5,%a1
	moveq	#0,%d0
	movew	%a5@(16),%d0		/* lib_NegSize */
	subal	%d0,%a1			/* block = lib - negsize */
	addw	%a5@(18),%d0		/* size = neg + pos */
	jsr	%a6@(-210)		/* FreeMem */
	movel	%d2,%d0			/* return seglist */
	moveml	%sp@+,%d2/%a5-%a6
	rts

/* ==== 0x0298 -24 reserved ======================================== */
_nullvec:
	moveq	#0,%d0
	rts

/* ==== 0x029c -30 alloc object (40 bytes, MEMF_PUBLIC|CLEAR) ======= */
_vec30:
	movel	%a6,%sp@-
	movel	%a6,%sp@-
	moveq	#40,%d0
	movel	#65537,%d1		/* MEMF_PUBLIC|MEMF_CLEAR */
	moveal	%a6@(38),%a6		/* ExecBase */
	jsr	%a6@(-198)		/* AllocMem */
	moveal	%sp@+,%a6
	moveal	%sp@+,%a6
	rts

/* ==== 0x02b6 -36 alloc object (34 bytes) ========================== */
_vec36:
	movel	%a6,%sp@-
	movel	%a6,%sp@-
	moveq	#34,%d0
	movel	#65537,%d1
	moveal	%a6@(38),%a6
	jsr	%a6@(-198)		/* AllocMem */
	moveal	%sp@+,%a6
	moveal	%sp@+,%a6
	rts

/* ==== 0x02d0 -42 free object (a0, 40) ============================= */
_vec42:
	moveml	%a3/%a6,%sp@-
	moveal	%a0,%a3
	movel	%a6,%sp@-
	moveal	%a3,%a1
	moveq	#40,%d0
	moveal	%a6@(38),%a6
	jsr	%a6@(-210)		/* FreeMem */
	moveal	%sp@+,%a6
	moveml	%sp@+,%a3/%a6
	rts

/* ==== 0x02ec -48 free object (a0, 34) ============================= */
_vec48:
	moveml	%a3/%a6,%sp@-
	moveal	%a0,%a3
	movel	%a6,%sp@-
	moveal	%a3,%a1
	moveq	#34,%d0
	moveal	%a6@(38),%a6
	jsr	%a6@(-210)		/* FreeMem */
	moveal	%sp@+,%a6
	moveml	%sp@+,%a3/%a6
	rts

/* ==== 0x0308 -66 'n' request: obj 72; in a0=str; out a1=rec ======= */
_vec66:
	linkw	%a5,#-20
	moveml	%d7/%a2-%a3/%a6,%sp@-
	moveml	%a0-%a1,%a5@(-20)	/* arg0@-20, arg1@-16 */
	movel	#501,%d7		/* default err code */
	clrl	%sp@-
	pea	0x48:w			/* request size 72 */
	movel	#0x800b1101,%sp@-
	jsr	%pc@(_mkobj)		/* nipc -114 tag-create */
	lea	%sp@(12),%sp
	moveal	%d0,%a3
	movel	%a3,%d0
	beqs	11f			/* alloc failed -> 501 */
	moveal	%a3@(42),%a2		/* data block */
	moveq	#32,%d0
	moveal	%a2,%a0
	moveal	%a5@(-20),%a1
	jsr	%pc@(_strncpy)		/* data+0 <- arg0 */
	moveq	#72,%d0
	movel	%d0,%a3@(50)		/* obj+50 = msg length */
	moveb	#110,%a3@(28)		/* cmd 'n' */
	moveal	%a3,%a0
	jsr	%pc@(_sendreq)		/* send + wait reply */
	tstw	%d0
	beqs	12f
	tstl	%a3@(30)		/* server status */
	bnes	13f
	moveq	#32,%d0
	moveal	%a5@(-16),%a0		/* arg1 out */
	moveal	%a2,%a1
	jsr	%pc@(_strncpy)		/* arg1 <- data+0 */
	moveal	%a5@(-16),%a0
	movew	%a2@(64),%a0@(32)
	movew	%a2@(66),%a0@(34)
	movel	%a2@(68),%a0@(36)
13:	movel	%a3@(30),%d7		/* result = obj+30 */
12:	movel	%a6,%sp@-
	moveal	%a3,%a1
	moveal	%a6@(34),%a6		/* NIPCBase */
	jsr	%a6@(-120)		/* nipc free object */
	moveal	%sp@+,%a6
11:	movel	%d7,%d0
	moveml	%sp@+,%d7/%a2-%a3/%a6
	unlk	%a5
	rts

/* ==== 0x03a0 -72 'p' request: obj 40; in a0=str; out a1+32 ======== */
_vec72:
	linkw	%a5,#-20
	moveml	%d7/%a2-%a3/%a6,%sp@-
	moveml	%a0-%a1,%a5@(-20)
	movel	#501,%d7
	clrl	%sp@-
	pea	0x28:w			/* request size 40 */
	movel	#0x800b1101,%sp@-
	jsr	%pc@(_mkobj)
	lea	%sp@(12),%sp
	moveal	%d0,%a3
	movel	%a3,%d0
	beqs	14f
	moveal	%a3@(42),%a2
	moveq	#32,%d0
	moveal	%a2,%a0
	moveal	%a5@(-20),%a1
	jsr	%pc@(_strncpy)
	moveq	#40,%d0
	movel	%d0,%a3@(50)
	moveb	#112,%a3@(28)		/* cmd 'p' */
	moveal	%a3,%a0
	jsr	%pc@(_sendreq)
	tstw	%d0
	beqs	15f
	tstl	%a3@(30)
	bnes	16f
	moveq	#32,%d0
	moveal	%a5@(-16),%a0
	moveal	%a2,%a1
	jsr	%pc@(_strncpy)
	moveal	%a5@(-16),%a0
	movew	%a2@(32),%a0@(32)
16:	movel	%a3@(30),%d7
15:	movel	%a6,%sp@-
	moveal	%a3,%a1
	moveal	%a6@(34),%a6
	jsr	%a6@(-120)
	moveal	%sp@+,%a6
14:	movel	%d7,%d0
	moveml	%sp@+,%d7/%a2-%a3/%a6
	unlk	%a5
	rts

/* ==== 0x042c -78 'm' request: obj 72; in d0=word,a0=str; out a1 === */
_vec78:
	linkw	%a5,#-16
	moveml	%d6-%d7/%a2-%a3/%a6,%sp@-
	movel	%d0,%d7			/* word arg */
	movel	%a0,%a5@(-16)		/* str arg */
	movel	#501,%d6
	clrl	%sp@-
	pea	0x48:w			/* request size 72 */
	movel	#0x800b1101,%sp@-
	jsr	%pc@(_mkobj)
	lea	%sp@(12),%sp
	moveal	%d0,%a3
	movel	%a3,%d0
	beqs	17f
	moveal	%a3@(42),%a2
	movew	%d7,%a2@(64)		/* data+64 = word arg */
	moveq	#72,%d0
	movel	%d0,%a3@(50)
	moveb	#109,%a3@(28)		/* cmd 'm' */
	moveal	%a3,%a0
	jsr	%pc@(_sendreq)
	tstw	%d0
	beqs	18f
	tstl	%a3@(30)
	bnes	19f
	moveq	#32,%d0
	moveal	%a5@(-16),%a0
	moveal	%a2,%a1
	jsr	%pc@(_strncpy)
	moveal	%a5@(-16),%a0
	movew	%a2@(64),%a0@(32)
	movew	%a2@(66),%a0@(34)
	movel	%a2@(68),%a0@(36)
19:	movel	%a3@(30),%d6
18:	movel	%a6,%sp@-
	moveal	%a3,%a1
	moveal	%a6@(34),%a6
	jsr	%a6@(-120)
	moveal	%sp@+,%a6
17:	movel	%d6,%d0
	moveml	%sp@+,%d6-%d7/%a2-%a3/%a6
	unlk	%a5
	rts

/* ==== 0x04bc -84 'o' request: obj 40; in d0=word,a0=str; out a1+32 = */
_vec84:
	linkw	%a5,#-16
	moveml	%d6-%d7/%a2-%a3/%a6,%sp@-
	movel	%d0,%d7
	movel	%a0,%a5@(-16)
	movel	#501,%d6
	clrl	%sp@-
	pea	0x28:w			/* request size 40 */
	movel	#0x800b1101,%sp@-
	jsr	%pc@(_mkobj)
	lea	%sp@(12),%sp
	moveal	%d0,%a3
	movel	%a3,%d0
	beqs	20f
	moveal	%a3@(42),%a2
	movew	%d7,%a2@(32)		/* data+32 = word arg */
	moveq	#40,%d0
	movel	%d0,%a3@(50)
	moveb	#111,%a3@(28)		/* cmd 'o' */
	moveal	%a3,%a0
	jsr	%pc@(_sendreq)
	tstw	%d0
	beqs	21f
	tstl	%a3@(30)
	bnes	22f
	moveq	#32,%d0
	moveal	%a5@(-16),%a0
	moveal	%a2,%a1
	jsr	%pc@(_strncpy)
	moveal	%a5@(-16),%a0
	movew	%a2@(32),%a0@(32)
22:	movel	%a3@(30),%d6
21:	movel	%a6,%sp@-
	moveal	%a3,%a1
	moveal	%a6@(34),%a6
	jsr	%a6@(-120)
	moveal	%sp@+,%a6
20:	movel	%d6,%d0
	moveml	%sp@+,%d6-%d7/%a2-%a3/%a6
	unlk	%a5
	rts

/* ==== 0x0540 -90 'j' request: obj 72; a0=rec in/out =============== */
_vec90:
	linkw	%a5,#-16
	moveml	%d7/%a2-%a3/%a6,%sp@-
	movel	%a0,%a5@(-16)		/* rec */
	movel	#501,%d7
	clrl	%sp@-
	pea	0x48:w			/* request size 72 */
	movel	#0x800b1101,%sp@-
	jsr	%pc@(_mkobj)
	lea	%sp@(12),%sp
	moveal	%d0,%a3
	movel	%a3,%d0
	beqs	23f
	moveal	%a3@(42),%a2
	moveq	#32,%d0
	moveal	%a2,%a0
	moveal	%a5@(-16),%a1
	jsr	%pc@(_strncpy)		/* data+0 <- arg+0 */
	moveal	%a5@(-16),%a0
	movew	%a0@(32),%a2@(64)	/* data+64 <- arg+32 */
	moveq	#72,%d0
	movel	%d0,%a3@(50)
	moveb	#106,%a3@(28)		/* cmd 'j' */
	moveal	%a3,%a0
	jsr	%pc@(_sendreq)
	tstw	%d0
	beqs	24f
	tstl	%a3@(30)
	bnes	25f
	moveq	#32,%d0
	moveal	%a5@(-16),%a0
	moveal	%a2,%a1
	jsr	%pc@(_strncpy)		/* arg <- data */
	moveal	%a5@(-16),%a0
	movew	%a2@(64),%a0@(32)
	movew	%a2@(66),%a0@(34)
	movel	%a2@(68),%a0@(36)
25:	movel	%a3@(30),%d7
24:	movel	%a6,%sp@-
	moveal	%a3,%a1
	moveal	%a6@(34),%a6
	jsr	%a6@(-120)
	moveal	%sp@+,%a6
23:	movel	%d7,%d0
	moveml	%sp@+,%d7/%a2-%a3/%a6
	unlk	%a5
	rts

/* ==== 0x05e0 -96 'l' request: obj 40; a0=rec in/out =============== */
_vec96:
	linkw	%a5,#-16
	moveml	%d7/%a2-%a3/%a6,%sp@-
	movel	%a0,%a5@(-16)
	movel	#501,%d7
	clrl	%sp@-
	pea	0x28:w			/* request size 40 */
	movel	#0x800b1101,%sp@-
	jsr	%pc@(_mkobj)
	lea	%sp@(12),%sp
	moveal	%d0,%a3
	movel	%a3,%d0
	beqs	26f
	moveal	%a3@(42),%a2
	moveq	#32,%d0
	moveal	%a2,%a0
	moveal	%a5@(-16),%a1
	jsr	%pc@(_strncpy)
	moveal	%a5@(-16),%a0
	movew	%a0@(32),%a2@(32)	/* data+32 <- arg+32 */
	moveq	#40,%d0
	movel	%d0,%a3@(50)
	moveb	#108,%a3@(28)		/* cmd 'l' */
	moveal	%a3,%a0
	jsr	%pc@(_sendreq)
	tstw	%d0
	beqs	27f
	tstl	%a3@(30)
	bnes	28f
	moveq	#32,%d0
	moveal	%a5@(-16),%a0
	moveal	%a2,%a1
	jsr	%pc@(_strncpy)
	moveal	%a5@(-16),%a0
	movew	%a2@(32),%a0@(32)
28:	movel	%a3@(30),%d7
27:	movel	%a6,%sp@-
	moveal	%a3,%a1
	moveal	%a6@(34),%a6
	jsr	%a6@(-120)
	moveal	%sp@+,%a6
26:	movel	%d7,%d0
	moveml	%sp@+,%d7/%a2-%a3/%a6
	unlk	%a5
	rts

/* ==== 0x0674 -102 'k' request: obj 112; a0/a1 recs in/out ========= */
_vec102:
	linkw	%a5,#-24
	moveml	%d7/%a2-%a3/%a6,%sp@-
	moveml	%a0-%a1,%a5@(-20)	/* arg0@-20, arg1@-16 */
	movel	#501,%d7
	clrl	%sp@-
	pea	0x70:w			/* request size 112 */
	movel	#0x800b1101,%sp@-
	jsr	%pc@(_mkobj)
	lea	%sp@(12),%sp
	moveal	%d0,%a3
	movel	%a3,%d0
	beqw	29f
	moveal	%a3@(42),%a2
	lea	%a2@(40),%a0
	movel	%a0,%sp@(16)		/* save data+40 */
	moveq	#32,%d0
	moveal	%a5@(-16),%a1
	jsr	%pc@(_strncpy)		/* data+40 <- arg1 */
	moveq	#32,%d0
	moveal	%a2,%a0
	moveal	%a5@(-20),%a1
	jsr	%pc@(_strncpy)		/* data+0 <- arg0 */
	moveal	%a5@(-16),%a0
	movew	%a0@(32),%a2@(104)	/* data+104 <- arg1+32 */
	moveal	%a5@(-20),%a0
	movew	%a0@(32),%a2@(32)	/* data+32 <- arg0+32 */
	moveq	#112,%d0
	movel	%d0,%a3@(50)
	moveb	#107,%a3@(28)		/* cmd 'k' */
	moveal	%a3,%a0
	jsr	%pc@(_sendreq)
	tstw	%d0
	beqs	30f
	tstl	%a3@(30)
	bnes	31f
	moveq	#32,%d0
	moveal	%a5@(-16),%a0		/* arg1 out */
	moveal	%sp@(16),%a1		/* data+40 */
	jsr	%pc@(_strncpy)		/* arg1 <- data+40 */
	moveal	%a5@(-16),%a0
	movew	%a2@(104),%a0@(32)
	movew	%a2@(106),%a0@(34)
	movel	%a2@(108),%a0@(36)
31:	movel	%a3@(30),%d7
30:	movel	%a6,%sp@-
	moveal	%a3,%a1
	moveal	%a6@(34),%a6
	jsr	%a6@(-120)
	moveal	%sp@+,%a6
29:	movel	%d7,%d0
	moveml	%sp@+,%d7/%a2-%a3/%a6
	unlk	%a5
	rts
	.short	0			/* pad to 4 (0x736) */

/* ==== 0x0738 shared 'q'/'u' request helper: d0=cmd, a0/a1=strs, ====
   a5@(8)=out struct (pushed by wrapper)                             */
_requ_qu:
	linkw	%a5,#-20
	moveml	%d6-%d7/%a2-%a3/%a6,%sp@-
	movel	%d0,%d7			/* cmd char */
	moveml	%a0-%a1,%a5@(-20)
	movel	#501,%d6
	clrl	%sp@-
	pea	0x48:w			/* request size 72 */
	movel	#0x800b1101,%sp@-
	jsr	%pc@(_mkobj)
	lea	%sp@(12),%sp
	moveal	%d0,%a3
	movel	%a3,%d0
	beqs	32f
	moveal	%a3@(42),%a2
	moveq	#32,%d0
	moveal	%a2,%a0
	moveal	%a5@(-20),%a1		/* arg0 */
	jsr	%pc@(_strncpy)		/* data+0 <- arg0 */
	lea	%a2@(32),%a0
	moveq	#32,%d0
	moveal	%a5@(-16),%a1		/* arg1 */
	jsr	%pc@(_strncpy)		/* data+32 <- arg1 */
	moveq	#72,%d0
	movel	%d0,%a3@(50)
	moveb	%d7,%a3@(28)		/* cmd = d0 param */
	moveal	%a3,%a0
	jsr	%pc@(_sendreq)
	tstw	%d0
	beqs	33f
	tstl	%a3@(30)
	bnes	34f
	moveq	#32,%d0
	moveal	%a5@(8),%a0		/* arg2 (caller's stacked a2) */
	moveal	%a2,%a1
	jsr	%pc@(_strncpy)		/* arg2 <- data+0 */
	moveal	%a5@(8),%a0
	movew	%a2@(64),%a0@(32)
	movew	%a2@(66),%a0@(34)
	movel	%a2@(68),%a0@(36)
34:	movel	%a3@(30),%d6
33:	movel	%a6,%sp@-
	moveal	%a3,%a1
	moveal	%a6@(34),%a6
	jsr	%a6@(-120)
	moveal	%sp@+,%a6
32:	movel	%d6,%d0
	moveml	%sp@+,%d6-%d7/%a2-%a3/%a6
	unlk	%a5
	rts

/* ==== 0x07de -60 't' request: obj 112; a0/a1 recs, status only ==== */
_vec60:
	linkw	%a5,#-16
	moveml	%d7/%a2-%a3/%a6,%sp@-
	moveal	%a0,%a3			/* arg0 */
	movel	%a1,%a5@(-12)		/* arg1 */
	movel	#501,%d7
	clrl	%sp@-
	pea	0x70:w			/* request size 112 */
	movel	#0x800b1101,%sp@-
	jsr	%pc@(_mkobj)
	lea	%sp@(12),%sp
	moveal	%d0,%a2			/* obj */
	movel	%a2,%d0
	beqs	35f
	moveal	%a2@(42),%a0		/* data */
	lea	%a0@(40),%a1		/* data+40 */
	movel	%a0,%sp@(16)		/* save data */
	moveal	%a1,%a0
	moveq	#32,%d0
	moveal	%a5@(-12),%a1		/* arg1 */
	jsr	%pc@(_strncpy)		/* data+40 <- arg1 */
	moveq	#32,%d0
	moveal	%sp@(16),%a0		/* data */
	moveal	%a3,%a1			/* arg0 */
	jsr	%pc@(_strncpy)		/* data+0 <- arg0 */
	moveal	%a5@(-12),%a0		/* arg1 */
	moveal	%sp@(16),%a1		/* data */
	movew	%a0@(32),%a1@(104)	/* data+104 <- arg1+32 */
	movew	%a3@(32),%a1@(32)	/* data+32 <- arg0+32 */
	moveq	#112,%d0
	movel	%d0,%a2@(50)
	moveb	#116,%a2@(28)		/* cmd 't' */
	moveal	%a2,%a0
	jsr	%pc@(_sendreq)
	tstw	%d0
	beqs	36f
	movel	%a2@(30),%d7		/* result = obj+30 (no copy-out) */
36:	movel	%a6,%sp@-
	moveal	%a2,%a1
	moveal	%a6@(34),%a6
	jsr	%a6@(-120)
	moveal	%sp@+,%a6
35:	movel	%d7,%d0
	moveml	%sp@+,%d7/%a2-%a3/%a6
	unlk	%a5
	rts

/* ==== 0x0876 -54 'q' wrapper: pass caller's a2 as stacked arg2 ==== */
_vec54:
	linkw	%a5,#-4
	moveml	%a2-%a3,%sp@-
	exg	%a2,%a1			/* a2=arg1; a1=caller's a2 */
	moveal	%a0,%a3			/* arg0 */
	movel	%a1,%a5@(-4)		/* stash caller's a2 */
	movel	%a5@(-4),%sp@-		/* becomes helper's a5@(8) = arg2 */
	moveq	#113,%d0		/* 'q' */
	moveal	%a3,%a0
	moveal	%a2,%a1
	bsrw	_requ_qu
	moveml	%a5@(-12),%a2-%a3
	unlk	%a5
	rts

/* ==== 0x089e -114 'u' wrapper ==================================== */
_vec114:
	linkw	%a5,#-4
	moveml	%a2-%a3,%sp@-
	exg	%a2,%a1
	moveal	%a0,%a3
	movel	%a1,%a5@(-4)
	movel	%a5@(-4),%sp@-
	moveq	#117,%d0		/* 'u' */
	moveal	%a3,%a0
	moveal	%a2,%a1
	bsrw	_requ_qu
	moveml	%a5@(-12),%a2-%a3
	unlk	%a5
	rts

/* ==== 0x08c6 -108 password hash ================================== */
/* a0=out(12B), a1=string arg, a2=name (32B, lowercased).            */
/* out = 11 chars: rolling hash of 12 longs (sum mod 53 + 'A')       */
_vec108:
	linkw	%a5,#-100
	moveml	%d6-%d7/%a2-%a3/%a6,%sp@-
	moveml	%a0-%a1,%a5@(-100)	/* arg0@-100 out, arg1@-96 str */
	lea	%a5@(-92),%a3		/* a3 = 32-byte lowercased name */
	moveq	#0,%d7
	bras	38f
37:	moveq	#0,%d0
	moveb	%a2@(0,%d7:l),%d0	/* name[i] */
	movel	%a6,%sp@-
	moveal	%a6@(46),%a6		/* UtilityBase */
	jsr	%a6@(-180)		/* ToLower */
	moveal	%sp@+,%a6
	moveb	%d0,%a5@(-92,%d7:l)	/* buf[i] = tolower(name[i]) */
	addql	#1,%d7
38:	moveq	#32,%d0
	cmpl	%d0,%d7
	blts	37b
	moveq	#0,%d7
	lea	%a5@(-60),%a2		/* a2 = 12-long mix buffer */
	bras	40f
39:	moveal	%a5@(-96),%a0		/* str arg walk */
	tstb	%a0@
	beqs	41f
	moveq	#0,%d0
	moveb	%a0@,%d0		/* *str */
	addql	#1,%a5@(-96)		/* str++ */
	bras	42f
41:	movel	%d7,%d0			/* exhausted -> i */
42:	movel	%d0,%d6
	tstb	%a3@
	beqs	43f
	moveq	#0,%d0
	moveb	%a3@+,%d0		/* *lname++ */
	bras	44f
43:	movel	%d7,%d0
44:	movel	%d6,%d1
	addl	%d0,%d1
	moveq	#65,%d0
	addl	%d0,%d1			/* char + str + 'A' */
	movel	%d1,%a2@+		/* mix[i] = d1 */
	addql	#1,%d7
40:	moveq	#12,%d0
	cmpl	%d0,%d7
	blts	39b
	moveq	#0,%d7
	lea	%a5@(-60),%a3		/* walk mix buffer */
	moveal	%a5@(-100),%a2		/* out */
	bras	46f
45:	moveq	#0,%d6
	bras	48f
47:	movel	%d6,%d0
	asll	#2,%d0
	lea	%a5@(-60),%a0
	subal	%d0,%a0			/* &mix[11-d6] */
	lea	%a0@(44),%a1
	movel	%a1@,%d0
	addl	%d0,%a3@		/* mix[d7] += mix[11-d6] */
	movel	%a6,%sp@-
	movel	%a3@,%d0
	moveq	#53,%d1
	moveal	%a6@(46),%a6		/* UtilityBase */
	jsr	%a6@(-156)		/* UDivMod32 */
	moveal	%sp@+,%a6
	movel	%d1,%a3@		/* mix[d7] %= 53 */
	addql	#1,%d6
48:	moveq	#12,%d0
	cmpl	%d0,%d6
	blts	47b
	moveq	#65,%d0
	addl	%a3@+,%d0		/* 'A' + mix[d7] (then a3++) */
	moveb	%d0,%a2@(0,%d7:l)	/* out[d7] */
	addql	#1,%d7
46:	lea	%a5@(-12),%a0
	cmpal	%a0,%a3			/* a3 < end of mix buf? */
	bcss	45b
	clrb	%a2@(11)		/* out[11] = 0 */
	movel	%a2,%d0			/* return out */
	moveml	%sp@+,%d6-%d7/%a2-%a3/%a6
	unlk	%a5
	rts
	.short	0			/* pad (0x992) */

/* ==== 0x0994 send request: a0=obj, a6=lib ======================== */
/* creates reply port, ships obj via nipc -156(entity,ctx,obj),
 * waits, gets msg (result ignored), deletes port. Returns 1/0.      */
_sendreq:
	linkw	%a5,#-4
	moveml	%d7/%a2-%a3/%a6,%sp@-
	moveal	%a0,%a3			/* obj */
	moveal	%a6,%a2			/* lib */
	moveq	#0,%d7
	movel	%a6,%sp@-
	moveal	%a6@(38),%a6		/* ExecBase */
	jsr	%a6@(-666)		/* CreateMsgPort */
	moveal	%sp@+,%a6
	movel	%d0,%sp@(16)		/* port -> frame local a5@(-4) */
	tstl	%d0
	beqs	49f
	movel	%d0,%a3@(14)		/* obj+14 = reply port */
	movel	%a3@(42),%a3@(54)	/* obj+54 = obj+42 (data ptr) */
	movel	%a3@(46),%a3@(58)	/* obj+58 = obj+46 */
	clrl	%a3@(30)		/* obj+30 = 0 (status) */
	movew	#5,%a3@(66)		/* obj+66 = 5 */
	moveml	%a2/%a6,%sp@-
	moveal	%a2@(58),%a0		/* entity */
	moveal	%a2@(54),%a1		/* context */
	moveal	%a3,%a2			/* obj */
	moveal	%a6@(34),%a6		/* NIPCBase */
	jsr	%a6@(-156)		/* nipc transaction */
	moveml	%sp@+,%a2/%a6
	movel	%a6,%sp@-
	moveal	%sp@(20),%a0		/* port */
	moveal	%a6@(38),%a6
	jsr	%a6@(-384)		/* WaitPort */
	moveal	%sp@+,%a6
	movel	%a6,%sp@-
	moveal	%sp@(20),%a0
	moveal	%a6@(38),%a6
	jsr	%a6@(-372)		/* GetMsg (result dropped) */
	moveal	%sp@+,%a6
	movel	%a6,%sp@-
	moveal	%sp@(20),%a0
	moveal	%a6@(38),%a6
	jsr	%a6@(-672)		/* DeleteMsgPort */
	moveal	%sp@+,%a6
	moveq	#1,%d7
49:	movel	%d7,%d0
	moveml	%sp@+,%d7/%a2-%a3/%a6
	unlk	%a5
	rts
	.short	0			/* pad (0xa26) */

/* ==== 0x0a28 object create: calls nipc -114(taglist) ============== */
/* caller pushed {0x800b1101, size, 0} on stack                      */
_mkobj:
	movel	%a6,%sp@-
	moveal	%a6@(34),%a6		/* NIPCBase */
	lea	%sp@(8),%a0		/* a0 -> taglist */
	jsr	%a6@(-114)		/* nipc alloc request object */
	moveml	%sp@+,%a6
	rts

/* ==== 0x0a3c sprintf wrapper (DEAD CODE - no callers) ============= */
/* arg0=dst, arg1=fmt, arg2...=varargs on stack                      */
_sprintf:
	moveml	%a2-%a4/%a6,%sp@-
	moveal	%sp@(20),%a3		/* dst */
	moveal	%sp@(24),%a0		/* fmt */
	lea	%sp@(28),%a1		/* &varargs */
	lea	%pc@(_putch),%a2		/* putch proc */
	moveal	%a6@(38),%a6		/* ExecBase */
	jsr	%a6@(-522)		/* RawDoFmt */
	moveml	%sp@+,%a2-%a4/%a6
	rts
_putch:
	moveb	%d0,%a3@+		/* RawDoFmt char sink */
	rts

/* ==== 0x0a62 bounded copy: a0=dst, a1=src, d0=count =============== */
/* copies d0 bytes, then writes 0 over dst[d0-1]                     */
_strncpy:
	subql	#1,%d0
	bmis	50f			/* d0==0 -> nothing */
51:	moveb	%a1@+,%a0@+
	dbeq	%d0,51b
	clrb	%a0@-			/* NUL-terminate */
50:	rts

_EndSkip:
