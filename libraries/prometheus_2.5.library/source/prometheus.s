/* prometheus.library 2.5 (22.07.2003) -- Matay / Grzegorz Kraszewski
 * Byte-identical reconstruction.
 *
 * hunk0 CODE (0x266 longs): DOS stub + RomTag + strings + all code.
 * hunk1 DATA (0x13 longs):  MakeLibrary-style function table
 *                           (18 absolute vectors + -1 terminator).
 *
 * RomTag: COLDSTART, version 2 (word), NT_LIBRARY pri 0.
 *   rt_Init -> h0+0x4ce (calls MakeLibrary itself, funcTable -> hunk1).
 *
 * Library base layout (0x54 bytes):
 *   +0x22 SysBase   +0x26 UtilityBase   +0x2a Prometheus.card base
 *   +0x2e seglist   +0x32 mempool       +0x36 board base addr
 *   +0x3a MinList pb_Cards (PCIBoard nodes)
 *   +0x46 List    pb_Requests (SpaceReq nodes)
 */

	.globl	_romtag,_init,_functab
	.globl	_open,_close,_expunge,_extfunc
	.globl	_findboard,_getattrs,_rdlong,_rdword,_rdbyte
	.globl	_wrlong,_wrword,_wrbyte,_setattrs,_addint,_remint
	.globl	_allocdma,_freedma,_getphys

	.text

/* ==== 0x000 stub ================================================ */
	moveq	#-1,%d0
	rts

/* ==== 0x004 RomTag ============================================== */
_romtag:
	.short	0x4afc
	.long	_romtag			/* MatchTag -> h0+4 */
	.long	_endskip		/* EndSkip  -> h0+0x1e */
	.byte	0,2,9,0			/* flags, ver2, NT_LIBRARY, pri */
	.long	_name			/* -> h0+0x20 */
	.long	_idstr			/* -> h0+0x34 */
	.long	_init			/* -> h0+0x4ce */
_endskip:
	.short	0

/* ==== 0x020 name ================================================ */
_name:
	.ascii	"prometheus.library"
	.byte	0,0

/* ==== 0x034 idstr =============================================== */
_idstr:
	.ascii	"$VER: prometheus.library 2.5 (22.07.2003) (c) 2000-2003 by Matay."
	.byte	10,0,0

/* ==== 0x078 SizeToPri(size) -> d0 : trailing-zero count ========= */
_sizetopri:
	movel	%sp@(4),%d1
	clrb	%d0
	btst	#0,%d1
	bnes	2f
1:	addqb	#1,%d0
	lsrl	#1,%d1
	btst	#0,%d1
	beqs	1b
2:	extbl	%d0
	rts
	nop					/* 0x92 pad */

/* ==== 0x094 AddRequest(pb,size,type,tag,cfgreg) ==================
 * arg1=pb, arg2=size, arg3=type(0=mem,1=io), arg4=&tagitem,
 * arg5=cfgreg; allocates 30B SpaceReq, Enqueue -> pb+0x46.
 */
_addreq:
	moveml	%d2-%d3/%a2-%a3/%a6,%sp@-
	moveal	%sp@(24),%a3		/* pb */
	movel	%sp@(28),%d3		/* size */
	movel	%a3@(34),%d2		/* SysBase */
	moveal	%d2,%a6
	moveal	%a3@(50),%a0		/* pool */
	moveq	#30,%d0
	jsr	%a6@(-708)		/* AllocPooled */
	moveal	%d0,%a2
	tstl	%a2
	beqs	3f
	movel	%d3,%a2@(14)		/* sr_Size */
	movel	%sp@(32),%a2@(18)	/* sr_Type */
	movel	%sp@(36),%a2@(22)	/* sr_Tag */
	movel	%sp@(40),%a2@(26)	/* sr_CfgAddr */
	moveb	#-2,%a2@(8)		/* ln_Type = 0xfe */
	movel	%d3,%sp@-
	bsrs	_sizetopri
	moveb	%d0,%a2@(9)		/* ln_Pri = log2(size) */
	addql	#4,%sp
	moveal	%d2,%a6
	lea	%a3@(70),%a0		/* &pb_Requests */
	moveal	%a2,%a1
	jsr	%a6@(-270)		/* Enqueue */
3:	moveml	%sp@+,%d2-%d3/%a2-%a3/%a6
	rts

/* ==== 0x0ee QueryCard(pb,cfg,cdev) ==============================
 * builds PCIBoard taglist, probes 5 BARs + ROM BAR, AddRequest each.
 *   a3 = cfg (PCI config space ptr), a0/sp@(60) = pb, sp@(68) = cdev.
 */
_querycard:
	lea	%sp@(-12),%sp
	moveml	%d2-%d7/%a2-%a6,%sp@-
	moveal	%sp@(64),%a3		/* cfg */
	moveal	%sp@(60),%a0		/* pb */
	movel	%a0@(34),%d3		/* SysBase */
	moveq	#5,%d4			/* tagindex = 5 */
	movew	%a3@,%d0		/* conf->vendor */
	cmpiw	#-1,%d0
	beqw	qc_done			/* no device -> out */
	moveal	%d3,%a6
	moveal	%a0@(50),%a0		/* pool */
	moveq	#67,%d0
	notb	%d0			/* 0xffffffbc = ~67 */
	jsr	%a6@(-708)		/* AllocPooled */
	moveal	%d0,%a2		/* PCIBoard node */
	movel	%a3,%d7
	andil	#65535,%d7		/* cfg & 0xffff */
	movel	%a3,%sp@(44)
	andil	#1792,%sp@(44)		/* cfg & 0x700 (func<<8) */
	tstl	%d0
	beqw	qc_notags
	moveal	%d3,%a6
	moveal	%sp@(60),%a1		/* pb */
	lea	%a1@(58),%a0		/* &pb_Cards */
	moveal	%d0,%a1
	jsr	%a6@(-246)		/* AddTailMinList */
	movel	%a3,%a2@(8)		/* pn_ConfigBase */
	movel	#0x6eda0000,%a2@(12)	/* PRM_Vendor */
	moveal	%d3,%a6
	jsr	%a6@(-636)		/* CacheClearU */
	movew	%a3@,%d0
	rolw	#8,%d0			/* bswap16 vendor */
	clrw	%a2@(16)
	movew	%d0,%a2@(18)
	movel	#0x6eda0001,%a2@(20)	/* PRM_Device */
	moveal	%d3,%a6
	jsr	%a6@(-636)
	movew	%a3@(2),%d0
	rolw	#8,%d0
	clrw	%a2@(24)
	movew	%d0,%a2@(26)
	movel	#0x6eda0002,%a2@(28)	/* PRM_Revision */
	moveal	%d3,%a6
	jsr	%a6@(-636)
	moveb	%a3@(8),%d0
	clrl	%a2@(32)
	moveb	%d0,%a2@(35)
	movel	#0x6eda0003,%a2@(36)	/* PRM_Class */
	moveal	%d3,%a6
	jsr	%a6@(-636)
	moveb	%a3@(11),%d0
	clrl	%a2@(40)
	moveb	%d0,%a2@(43)
	movel	#0x6eda0004,%a2@(44)	/* PRM_SubClass */
	moveal	%d3,%a6
	jsr	%a6@(-636)
	moveb	%a3@(10),%d0
	clrl	%a2@(48)
	moveb	%d0,%a2@(51)
	clrw	%d5			/* i = 0 */
	lea	%a2@(16),%a0
	movel	%a0,%sp@(48)		/* save &tag[] data base */
	clrl	%d6
	lea	%a3@(16),%a5		/* &cfg->BAR[0] */
	lea	%a2@(12),%a4		/* taglist base */
qc_barloop:
	moveal	%d3,%a6
	jsr	%a6@(-636)		/* CacheClearU */
	movew	%d5,%d6
	movel	%d6,%d2
	lsll	#2,%d2
	moveq	#-1,%d0
	movel	%d0,%a5@(0,%d2:l)	/* BAR[i] = ~0 (size probe) */
	moveal	%d3,%a6
	jsr	%a6@(-636)
	movel	%a5@(0,%d2:l),%d2	/* read back mask */
	rolw	#8,%d2
	swap	%d2
	rolw	#8,%d2			/* bswap32 */
	moveq	#-1,%d1
	cmpl	%d2,%d1
	bnes	4f
	clrl	%d2			/* ~0 read -> size 0 */
4:	tstl	%d2
	beqs	qc_nextbar
	btst	#0,%d2			/* IO-space BAR? */
	beqs	5f
	moveaw	#1,%a0			/* type = 1 (IO) */
	moveq	#-4,%d0
	andl	%d0,%d2			/* mask &= ~3 */
	bras	6f
5:	subal	%a0,%a0			/* type = 0 (MEM) */
	moveq	#-16,%d1
	andl	%d1,%d2			/* mask &= ~15 */
6:	negl	%d2			/* size = -mask */
	movew	%d4,%d0
	extl	%d0
	lsll	#3,%d0			/* tagindex*8 */
	clrl	%d1
	movew	%d5,%d1
	moveal	%d1,%a1
	addal	#0x6eda0020,%a1		/* PRM_MemorySize0+i */
	movel	%a1,%a4@(0,%d0:l)	/* ->ti_Tag */
	moveal	%sp@(48),%a1		/* &data */
	movel	%d2,%a1@(0,%d0:l)	/* ->ti_Data = size */
	addqw	#1,%d4
	movew	%d4,%d0
	extl	%d0
	lsll	#3,%d0
	moveal	%d1,%a1
	addal	#0x6eda0010,%a1		/* PRM_MemoryAddr0+i */
	movel	%a1,%a4@(0,%d0:l)
	pea	%a3@(16,%d1:l:4)	/* arg5 = &cfg->BAR[i] */
	pea	%a2@(12,%d0:l)		/* arg4 = &addr tagitem */
	addqw	#1,%d4
	movel	%a0,%sp@-		/* arg3 = type */
	movel	%d2,%sp@-		/* arg2 = size */
	movel	%sp@(76),%sp@-		/* arg1 = pb */
	bsrw	_addreq
	lea	%sp@(20),%sp
qc_nextbar:
	addqw	#1,%d5
	cmpiw	#5,%d5
	blsw	qc_barloop
	moveal	%d3,%a6
	jsr	%a6@(-636)
	movel	#0xfeffffff,%a3@(48)	/* ROM BAR probe = ~1MB */
	moveal	%d3,%a6
	jsr	%a6@(-636)
	movel	%a3@(48),%d2
	rolw	#8,%d2
	swap	%d2
	rolw	#8,%d2			/* bswap32 readback */
	moveq	#-1,%d0
	cmpl	%d2,%d0
	bnes	7f
	clrl	%d2
7:	tstl	%d2
	beqs	qc_notags
	andiw	#-2048,%d2		/* rommask & 0xf800 */
	negl	%d2			/* romsize */
	movew	%d4,%d0
	extl	%d0
	lsll	#3,%d0
	lea	%a2@(12),%a0
	movel	#0x6eda0026,%a0@(0,%d0:l)	/* PRM_ROM_Size */
	movel	%d2,%a2@(16,%d0:l)	/* ->ti_Data = size */
	addqw	#1,%d4
	movew	%d4,%d0
	extl	%d0
	lsll	#3,%d0
	movel	#0x6eda0016,%a0@(0,%d0:l)	/* PRM_ROM_Address */
	pea	%a3@(48)		/* arg5 = &cfg->ROMBAR */
	pea	%a2@(12,%d0:l)		/* arg4 = &tagitem */
	addqw	#1,%d4
	clrl	%sp@-			/* arg3 = 0 (mem) */
	movel	%d2,%sp@-		/* arg2 = romsize */
	movel	%sp@(76),%sp@-		/* arg1 = pb */
	bsrw	_addreq
	lea	%sp@(20),%sp
qc_notags:
	movew	%d4,%d0
	extl	%d0
	lsll	#3,%d0
	lea	%a2@(12),%a0
	movel	#0x6eda0005,%a0@(0,%d0:l)	/* PRM_BoardOwner */
	lea	%a2@(16),%a1
	clrl	%a1@(0,%d0:l)		/* ->ti_Data = 0 */
	addqw	#1,%d4
	movew	%d4,%d0
	extl	%d0
	lsll	#3,%d0
	movel	#0x6eda0006,%a0@(0,%d0:l)	/* PRM_SlotNumber */
	moveq	#13,%d1
	lsrl	%d1,%d7			/* (cfg&0xffff)>>13 = slot */
	movel	%d7,%a1@(0,%d0:l)
	addqw	#1,%d4
	movew	%d4,%d0
	extl	%d0
	lsll	#3,%d0
	movel	#0x6eda0007,%a0@(0,%d0:l)	/* PRM_FunctionNumber */
	movel	%sp@(44),%d1
	lsrl	#8,%d1			/* (cfg&0x700)>>8 = function */
	movel	%d1,%a1@(0,%d0:l)
qc_done:
	moveml	%sp@+,%d2-%d7/%a2-%a6
	lea	%sp@(12),%sp
	rts

/* ==== 0x346 WriteAddresses(pb,cdev) ==============================
 * walks pb_Requests (lib+0x46), assigns PCI BAR addresses descending.
 *   mem cursor d3 = boardaddr+boardsize, io cursor d2 = board+0xf0000.
 */
_writeaddr:
	moveml	%d2-%d5/%a2-%a3/%a6,%sp@-
	moveal	%sp@(32),%a0		/* pb */
	moveal	%sp@(36),%a3		/* cdev */
	movel	%a0@(34),%d5		/* SysBase */
	movel	%a3@(36),%d1		/* cd_BoardSize */
	movel	%d1,%d4
	subql	#1,%d4			/* sizemask */
	movel	%a3@(32),%d0		/* cd_BoardAddr */
	movel	%d0,%d3
	addl	%d1,%d3			/* mem cursor = addr+size */
	movel	%d0,%d2
	addil	#983040,%d2		/* io cursor = addr+0xf0000 */
	moveal	%a0@(70),%a2		/* requests head */
	bras	wa_sub			/* -> test at 0x3be */
wa_node:
	tstl	%a0			/* sr_Type==0? */
	beqs	wa_mem
	moveq	#1,%d0
	cmpl	%a0,%d0
	beqs	wa_io
	bras	wa_clear
wa_mem:
	moveal	%a2@(26),%a0		/* sr_CfgAddr */
	movel	%d3,%d0
	moveq	#1,%d1
	orl	%d1,%d0
	andl	%d4,%d0			/* (mem|1)&sizemask */
	rolw	#8,%d0
	swap	%d0
	rolw	#8,%d0			/* bswap */
	movel	%d0,%a0@		/* *cfgreg = val */
	moveal	%a2@(22),%a0		/* sr_Tag */
	movel	%d3,%a0@(4)		/* ti_Data = addr */
	bras	wa_clear
wa_io:
	moveal	%a2@(26),%a0
	movel	%d2,%d0
	andl	%d4,%d0			/* io&sizemask */
	rolw	#8,%d0
	swap	%d0
	rolw	#8,%d0
	movel	%d0,%a0@
	moveal	%a2@(22),%a0
	movel	%d2,%a0@(4)
wa_clear:
	moveal	%d5,%a6
	jsr	%a6@(-636)		/* CacheClearU */
	moveal	%a2@,%a2		/* ln_Succ */
wa_sub:
	tstl	%a2@
	beqs	wa_out			/* last node skipped */
	movel	%a2@(18),%d0		/* sr_Type */
	moveal	%d0,%a0
	beqs	8f			/* mem request */
	moveq	#1,%d1
	cmpl	%d0,%d1
	beqs	9f			/* io request */
	bras	wa_bounds
8:	subl	%a2@(14),%d3		/* mem -= size */
	bras	wa_bounds
9:	subl	%a2@(14),%d2		/* io -= size */
wa_bounds:
	movel	%a3@(32),%d1		/* boardaddr */
	movel	%d1,%d0
	addil	#1048576,%d0		/* +0x100000 */
	cmpl	%d3,%d0
	bccs	wa_out			/* mem cursor below floor */
	addil	#-983040,%d0		/* +0x10000 */
	cmpl	%d2,%d0
	bcsw	wa_node			/* io still above floor */
wa_out:
	moveml	%sp@+,%d2-%d5/%a2-%a3/%a6
	rts

/* ==== 0x3fe ScanBoard(pb,cdev) ===================================
 * NewList(pb_Requests), store boardaddr, scan 4 slots x 1|8 funcs,
 * write cmd=0x0700/latency=0, then WriteAddresses, set cd_Driver.
 */
_scanboard:
	subqw	#8,%sp
	moveml	%d2-%d5/%a2-%a4,%sp@-
	moveal	%sp@(40),%a3		/* pb */
	moveal	%sp@(44),%a4		/* cdev */
	lea	%a3@(74),%a0		/* &tail */
	movel	%a0,%a3@(70)		/* head = &tail */
	clrl	%a0@			/* tail = NULL */
	lea	%a3@(70),%a0
	movel	%a0,%a3@(78)		/* tailpred = &head */
	moveb	#-2,%a3@(82)		/* lh_Type = 0xfe */
	movel	%a4@(32),%a3@(54)	/* pb->boardaddr = cd_BoardAddr */
	movel	%a4@(32),%d0
	addil	#983040,%d0		/* +0xf0000 */
	movel	%d0,%sp@(28)		/* cfgbase */
	clrw	%d1			/* slot counter */
sb_scan:
	moveal	%sp@(28),%a2		/* cfgspace */
	moveb	%a2@(14),%d0		/* conf->headertype */
	moveq	#1,%d4			/* funcs = 1 */
	tstb	%d0
	bges	10f			/* bit7 clear -> single func */
	moveq	#8,%d4			/* multifunction -> 8 */
10:	clrw	%d3			/* func = 0 */
	movew	%d1,%d5
	addqw	#1,%d5			/* slots done+1 */
	cmpw	%d3,%d4
	bles	sb_nextslot
sb_funcloop:
	movel	%a4,%sp@-		/* cdev */
	movew	%d3,%d2
	extl	%d2
	lsll	#8,%d2			/* func<<8 */
	pea	%a2@(0,%d2:l)		/* cfg+func*256 */
	movel	%a3,%sp@-		/* pb */
	bsrw	_querycard
	movew	#1792,%a2@(4,%d2:l)	/* cfg->command = 0x0700 */
	clrb	%a2@(13,%d2:l)		/* cfg->latency = 0 */
	lea	%sp@(12),%sp
	addqw	#1,%d3
	cmpw	%d3,%d4
	bgts	sb_funcloop
sb_nextslot:
	movel	%sp@(28),%d0
	addil	#8192,%d0		/* +0x2000 */
	movel	%d0,%sp@(28)
	movew	%d5,%d1
	cmpiw	#3,%d1
	bles	sb_scan			/* 4 slots */
	movel	%a4,%sp@-		/* cdev */
	movel	%a3,%sp@-		/* pb */
	bsrw	_writeaddr
	movel	%a3,%a4@(44)		/* cd_Driver = pb */
	andib	#-3,%a4@(14)		/* cd_Flags &= ~2 */
	addql	#8,%sp
	moveml	%sp@+,%d2-%d5/%a2-%a4
	addqw	#8,%sp
	rts

/* ==== 0x4ac strings ============================================= */
_s_util:
	.ascii	"utility.library\0"	/* 0x4ac */
_s_exp:
	.ascii	"expansion.library\0"	/* 0x4bc */

/* ==== 0x4ce rt_Init (COLDSTART) ==================================
 * a0 = seglist, a6 = SysBase.
 */
_init:
	moveml	%d2-%d6/%a2/%a6,%sp@-
	movel	%a0,%d2			/* seglist */
	movel	%a6,%d3			/* SysBase */
	clrl	%d6			/* result = NULL */
	clrl	%d4			/* cdev = NULL */
	.short	0x41f9
	.long	_functab		/* lea _functab.l,a0 -> hunk1 */
	subal	%a1,%a1			/* structinit = NULL */
	subal	%a2,%a2			/* data init = NULL */
	moveq	#84,%d0			/* libSize */
	clrl	%d1			/* seglist */
	jsr	%a6@(-84)		/* MakeLibrary */
	moveal	%d0,%a2			/* pb */
	tstl	%a2
	beqw	in_out
	moveb	#9,%a2@(8)		/* ln_Type = NT_LIBRARY */
	.short	0x2579
	.long	_romtag+0x0e		/* movel romtag.rt_Name.l,a2@(10) */
	.short	0x000a
	moveb	#6,%a2@(14)		/* lib_Flags = CHANGED|SUMUSED */
	movew	#2,%a2@(20)		/* lib_Version = 2 */
	movew	#5,%a2@(22)		/* lib_Revision = 5 */
	.short	0x2579
	.long	_romtag+0x12		/* movel romtag.rt_IdString.l,a2@(24) */
	.short	0x0018
	movew	#1,%a2@(32)		/* lib_OpenCnt = 1 */
	movel	%d2,%a2@(46)		/* seglist */
	movel	%a6,%a2@(34)		/* SysBase */
	clrl	%a2@(42)		/* cardbase = NULL */
	lea	%a2@(62),%a0
	movel	%a0,%a2@(58)		/* pb_Cards.mlh_Head = &tail */
	clrl	%a0@			/* mlh_Tail = NULL */
	lea	%a2@(58),%a0
	movel	%a0,%a2@(66)		/* mlh_TailPred = &head */
	moveal	%d3,%a6			/* SysBase */
	moveq	#1,%d0
	swap	%d0			/* MEMF_CLEAR */
	movel	#752,%d1		/* puddle 4*188 */
	movel	%d1,%d2			/* thresh */
	jsr	%a6@(-696)		/* CreatePool */
	movel	%d0,%a2@(50)		/* pool */
	beqs	in_out
	moveal	%d3,%a6
	moveal	%a2,%a1
	jsr	%a6@(-396)		/* AddLibrary */
	moveal	%d3,%a6
	lea	%pc@(_s_util),%a1
	moveq	#36,%d0
	jsr	%a6@(-552)		/* OpenLibrary("utility.library",36) */
	movel	%d0,%d5
	beqs	in_out
	movel	%d0,%a2@(38)		/* UtilityBase */
	moveal	%d3,%a6
	lea	%pc@(_s_exp),%a1
	moveq	#36,%d0
	jsr	%a6@(-552)		/* OpenLibrary("expansion.library",36) */
	movel	%d0,%d2			/* expansion base */
	beqs	in_noexp
	bras	in_find
in_scan:
	movel	%d0,%sp@-		/* cdev */
	movel	%a2,%sp@-		/* pb */
	bsrw	_scanboard
	addql	#8,%sp
in_find:
	moveal	%d2,%a6			/* expansion */
	moveal	%d4,%a0			/* prev cdev */
	movel	#44359,%d0		/* manufacturer 0xad47 */
	moveq	#1,%d1			/* product 1 */
	jsr	%a6@(-72)		/* FindConfigDev */
	movel	%d0,%d4
	bnes	in_scan
	movel	%a2,%d6			/* result = pb */
	moveal	%d3,%a6
	moveal	%d2,%a1
	jsr	%a6@(-414)		/* CloseLibrary(expansion) */
in_noexp:
	tstl	%d6
	bnes	in_out
	moveal	%d3,%a6
	moveal	%d5,%a1
	jsr	%a6@(-414)		/* CloseLibrary(utility) */
	clrl	%a2@(38)
in_out:
	movel	%d6,%d0
	moveml	%sp@+,%d2-%d6/%a2/%a6
	rts

/* ==== 0x5c6 Open ================================================ */
_open:
	movel	%a6,%sp@-
	addqw	#1,%a6@(32)		/* lib_OpenCnt++ */
	andib	#-9,%a6@(14)		/* clear LIBF_DELEXP */
	movel	%a6,%d0
	moveal	%sp@+,%a6
	rts

/* ==== 0x5d8 Close =============================================== */
_close:
	movel	%a6,%sp@-
	movew	%a6@(32),%d0
	movew	%d0,%d1
	subqw	#1,%d1
	movew	%d1,%a6@(32)		/* lib_OpenCnt-- */
	cmpiw	#1,%d0
	bnes	11f			/* not last close */
	btst	#3,%a6@(14)		/* LIBF_DELEXP? */
	beqs	11f
	bsrs	_expunge		/* deferred expunge */
	bras	12f
11:	clrl	%d0
12:	moveal	%sp@+,%a6
	rts

/* ==== 0x5fe Expunge ============================================= */
_expunge:
	moveml	%d2-%d3/%a2/%a6,%sp@-
	moveal	%a6,%a2			/* libbase */
	movel	%a2@(34),%d3		/* SysBase */
	tstw	%a2@(32)		/* opencnt */
	beqs	13f
	orib	#8,%a2@(14)		/* set LIBF_DELEXP */
	clrl	%d0
	bras	ex_out
13:	moveal	%d3,%a6
	moveal	%a2,%a1
	jsr	%a6@(-252)		/* Remove */
	movel	%a2@(50),%d0		/* pool */
	beqs	14f
	moveal	%d3,%a6
	moveal	%d0,%a0
	jsr	%a6@(-702)		/* DeletePool */
14:	movel	%a2@(38),%d0		/* utility base */
	beqs	15f
	moveal	%d3,%a6
	moveal	%d0,%a1
	jsr	%a6@(-414)		/* CloseLibrary */
15:	movel	%a2@(42),%d0		/* card base */
	beqs	16f
	moveal	%d3,%a6
	moveal	%d0,%a1
	jsr	%a6@(-414)		/* CloseLibrary */
16:	movel	%a2@(46),%d2		/* seglist */
	clrl	%d0
	movew	%a2@(16),%d0		/* lib_NegSize */
	clrl	%d1
	movew	%a2@(18),%d1		/* lib_PosSize */
	moveal	%d3,%a6
	moveal	%a2,%a1
	subal	%d0,%a1			/* base -= negsize */
	addl	%d1,%d0			/* size = neg+pos */
	jsr	%a6@(-210)		/* FreeMem */
	movel	%d2,%d0			/* return seglist */
ex_out:
	moveml	%sp@+,%d2-%d3/%a2/%a6
	rts

/* ==== 0x66e ExtFunc (reserved) ================================== */
_extfunc:
	clrl	%d0
	rts
	nop					/* 0x672 pad */

/* ==== 0x674 Prm_FindBoardTagList(a0=node,a1=taglist) ============= */
_findboard:
	subqw	#8,%sp
	moveml	%d2-%d6/%a2-%a3/%a6,%sp@-
	moveal	%a0,%a3			/* node */
	movel	%a1,%d5			/* taglist */
	movel	%a6@(38),%d4		/* UtilityBase */
	tstl	%a3
	bnes	17f
	moveal	%a6@(58),%a3		/* pb_Cards.mlh_Head */
	bras	fb_test
fb_found:
	movel	%a3,%d0			/* return node */
	bras	fb_out
17:	moveal	%a3@,%a3		/* mln_Succ */
fb_test:
	tstl	%a3@
	beqs	fb_null			/* tail -> NULL */
	moveq	#32,%d6
	addl	%sp,%d6			/* &tagptr local */
fb_node:
	movel	%d5,%sp@(32)		/* tagptr = taglist */
	beqs	fb_found		/* null taglist -> match */
	movel	%d6,%d3
	moveq	#12,%d2
	addl	%a3,%d2			/* node->pn_TagList */
fb_tagloop:
	moveal	%d4,%a6			/* utility */
	moveal	%d3,%a0
	jsr	%a6@(-48)		/* NextTagItem(&tagptr) */
	moveal	%d0,%a2			/* tag */
	tstl	%a2
	beqs	18f
	moveal	%d4,%a6
	movel	%a2@,%d0		/* tag->ti_Tag */
	moveal	%d2,%a0		/* node taglist */
	jsr	%a6@(-30)		/* FindTagItem */
	moveal	%d0,%a0			/* tagbase */
	tstl	%a0
	beqs	fb_tagloop		/* missing -> next tag */
	moveal	%a0@(4),%a0		/* tagbase->ti_Data */
	cmpal	%a2@(4),%a0
	beqs	fb_tagloop		/* equal -> next tag */
18:	tstl	%a2
	beqs	fb_found		/* tagptr exhausted -> match */
	moveal	%a3@,%a3		/* next node */
	tstl	%a3@
	bnes	fb_node			/* -> 0x69a */
fb_null:
	clrl	%d0
fb_out:
	moveml	%sp@+,%d2-%d6/%a2-%a3/%a6
	addqw	#8,%sp
	rts

/* ==== 0x6e2 Prm_GetBoardAttrsTagList(a0=board,a1=taglist) ======== */
_getattrs:
	subqw	#8,%sp
	moveml	%d2-%d5/%a2/%a6,%sp@-
	movel	%a0,%d4			/* board */
	movel	%a1,%d0			/* taglist */
	movel	%a6@(38),%d3		/* UtilityBase */
	clrl	%d5			/* count */
	tstl	%d4
	beqs	ga_out			/* no board */
	tstl	%d0
	beqs	ga_out			/* no taglist */
	movel	%d0,%sp@(24)		/* tagptr local */
	moveq	#24,%d2
	addl	%sp,%d2			/* &tagptr */
	bras	ga_next
ga_item:
	tstl	%a2@(4)			/* tag->ti_Data */
	beqs	ga_next			/* NULL dest -> skip */
	moveal	%d3,%a6
	movel	%a2@,%d0		/* ti_Tag */
	moveal	%d4,%a1
	lea	%a1@(12),%a0		/* board->pn_TagList */
	jsr	%a6@(-30)		/* FindTagItem */
	moveal	%d0,%a1			/* tagbase */
	tstl	%d0
	beqs	ga_clear
	moveal	%a2@(4),%a0		/* tag->ti_Data ptr */
	movel	%a1@(4),%a0@		/* *dest = found data */
	addql	#1,%d5
	bras	ga_next
ga_clear:
	moveal	%a2@(4),%a0
	movel	%d0,%a0@		/* *dest = 0 */
ga_next:
	moveal	%d3,%a6
	moveal	%d2,%a0
	jsr	%a6@(-48)		/* NextTagItem(&tagptr) */
	moveal	%d0,%a2
	tstl	%a2
	bnes	ga_item
ga_out:
	movel	%d5,%d0
	moveml	%sp@+,%d2-%d5/%a2/%a6
	addqw	#8,%sp
	rts

/* ==== 0x748 Prm_ReadConfigLong(a0=board,d0=offset) -> d0 ========= */
_rdlong:
	moveml	%d2/%a2/%a6,%sp@-
	moveb	%d0,%d2			/* offset */
	moveal	%a0@(8),%a2		/* pn_ConfigBase */
	moveal	%a6@(34),%a6		/* SysBase */
	jsr	%a6@(-636)		/* CacheClearU */
	.short	0xe9c2,0x2606		/* bfextu d2{24:6},d2 = off>>2&63 */
	movel	%a2@(0,%d2:l:4),%d0
	rolw	#8,%d0
	swap	%d0
	rolw	#8,%d0			/* bswap32 */
	moveml	%sp@+,%d2/%a2/%a6
	rts

/* ==== 0x76e Prm_ReadConfigWord(a0=board,d0=offset) -> d0 ========= */
_rdword:
	moveml	%d2/%a2/%a6,%sp@-
	moveb	%d0,%d2
	moveal	%a0@(8),%a2
	moveal	%a6@(34),%a6
	jsr	%a6@(-636)
	.short	0xe9c2,0x2607		/* bfextu d2{24:7},d2 = off>>1&127 */
	eoriw	#1,%d2			/* word-in-long swap */
	movew	%a2@(0,%d2:l:2),%d0
	rolw	#8,%d0			/* bswap16 */
	andil	#65535,%d0
	moveml	%sp@+,%d2/%a2/%a6
	rts

/* ==== 0x79a Prm_ReadConfigByte(a0=board,d0=offset) -> d0 ========= */
_rdbyte:
	moveml	%d2/%a2/%a6,%sp@-
	moveb	%d0,%d2
	moveal	%a0@(8),%a2
	moveal	%a6@(34),%a6
	jsr	%a6@(-636)
	eorib	#3,%d2			/* byte-in-word swap */
	andil	#255,%d2
	moveb	%a2@(0,%d2:l),%d0
	andil	#255,%d0
	moveml	%sp@+,%d2/%a2/%a6
	rts

/* ==== 0x7c6 Prm_WriteConfigLong(a0=board,d0=offset,d1=data) ======
 * NOTE: 2.5 has the "data/offset regs reversed" quirk vs the docs
 * (fixed only in v3.0): here d0 is the offset and d1 the data.
 */
_wrlong:
	movel	%a6,%sp@-
	moveal	%a0@(8),%a0		/* pn_ConfigBase */
	moveal	%a6@(34),%a6		/* SysBase */
	.short	0xe9c0,0x0606		/* bfextu d0{24:6},d0 */
	rolw	#8,%d1
	swap	%d1
	rolw	#8,%d1			/* bswap32 data */
	movel	%d1,%a0@(0,%d0:l:4)
	jsr	%a6@(-636)		/* CacheClearU */
	moveal	%sp@+,%a6
	rts

/* ==== 0x7e6 Prm_WriteConfigWord(a0=board,d0=offset,d1=data) ====== */
_wrword:
	movel	%a6,%sp@-
	moveal	%a0@(8),%a0
	moveal	%a6@(34),%a6
	.short	0xe9c0,0x0607		/* bfextu d0{24:7},d0 */
	eoriw	#1,%d0
	rolw	#8,%d1			/* bswap16 data */
	movew	%d1,%a0@(0,%d0:l:2)
	jsr	%a6@(-636)
	moveal	%sp@+,%a6
	rts

/* ==== 0x806 Prm_WriteConfigByte(a0=board,d0=offset,d1=data) ====== */
_wrbyte:
	movel	%a6,%sp@-
	moveal	%a0@(8),%a0
	moveal	%a6@(34),%a6
	eorib	#3,%d0
	andil	#255,%d0
	moveb	%d1,%a0@(0,%d0:l)
	jsr	%a6@(-636)
	moveal	%sp@+,%a6
	rts

/* ==== 0x826 SettableTags = {PRM_BoardOwner, TAG_END} ============= */
_settable:
	.long	0x6eda0005
	.long	0

/* ==== 0x82e Prm_SetBoardAttrsTagList(a0=board,a1=taglist) ======== */
_setattrs:
	subqw	#8,%sp
	moveml	%d2-%d5/%a2/%a6,%sp@-
	movel	%a0,%d4			/* board */
	movel	%a1,%d0			/* taglist */
	clrl	%d5			/* count */
	movel	%d0,%sp@(24)		/* tagptr */
	movel	%a6@(38),%d2		/* UtilityBase */
	tstl	%d4
	beqs	sa_out
	tstl	%d0
	beqs	sa_out
	moveq	#24,%d3
	addl	%sp,%d3			/* &tagptr */
	bras	sa_next
sa_item:
	moveal	%d2,%a6			/* utility */
	movel	%a2@,%d0		/* tag->ti_Tag */
	lea	%pc@(_settable),%a0
	jsr	%a6@(-90)		/* TagInArray */
	tstw	%d0
	beqs	sa_next			/* not settable -> skip */
	moveal	%d2,%a6
	movel	#0x6eda0005,%d0		/* PRM_BoardOwner */
	moveal	%d4,%a1
	lea	%a1@(12),%a0		/* board->pn_TagList */
	jsr	%a6@(-30)		/* FindTagItem */
	moveal	%d0,%a0			/* dbasetag */
	tstl	%a0
	beqs	sa_next
	cmpl	#0x6eda0005,%a2@	/* tag == PRM_BoardOwner? */
	bnes	sa_next
	tstl	%a0@(4)			/* dbasetag->ti_Data == 0? */
	beqs	sa_set
	tstl	%a2@(4)			/* or item->ti_Data == 0? */
	bnes	sa_next
sa_set:
	movel	%a2@(4),%a0@(4)		/* copy new owner */
	addql	#1,%d5
sa_next:
	moveal	%d2,%a6
	moveal	%d3,%a0
	jsr	%a6@(-48)		/* NextTagItem(&tagptr) */
	moveal	%d0,%a2
	tstl	%a2
	bnes	sa_item
sa_out:
	movel	%d5,%d0
	moveml	%sp@+,%d2-%d5/%a2/%a6
	addqw	#8,%sp
	rts

/* ==== 0x8ac Prm_AddIntServer(a0=board,a1=intr) -> bool =========== */
_addint:
	movel	%a6,%sp@-
	movel	%a1,%d1			/* intr */
	movel	%a6@(34),%d0		/* SysBase */
	tstl	%a0			/* board */
	beqs	19f
	moveal	%d0,%a6
	moveq	#3,%d0			/* INTB_PORTS? intnum 3 */
	jsr	%a6@(-168)		/* AddIntServer */
	moveq	#1,%d0
	bras	20f
19:	clrl	%d0
20:	moveal	%sp@+,%a6
	rts

/* ==== 0x8ca Prm_RemIntServer(a0=board,a1=intr) =================== */
_remint:
	movel	%a6,%sp@-
	movel	%a1,%d1			/* intr */
	movel	%a6@(34),%d0		/* SysBase */
	tstl	%a0
	beqs	21f
	tstl	%d1
	beqs	21f
	moveal	%d0,%a6
	moveq	#3,%d0
	jsr	%a6@(-174)		/* RemIntServer */
21:	moveal	%sp@+,%a6
	rts

/* ==== 0x8e6 "Prometheus.card" =================================== */
_s_card:
	.ascii	"Prometheus.card\0"

/* ==== 0x8f6 Prm_AllocDMABuffer(d0=size) ==========================
 * lazy-opens "Prometheus.card" v7 into lib+42, calls its -42 vector.
 */
_allocdma:
	moveml	%d2/%a2/%a6,%sp@-
	moveal	%a6,%a2			/* lib */
	movel	%d0,%d2			/* size */
	movel	%a2@(34),%d0		/* SysBase */
	tstl	%a2@(42)		/* cardbase */
	bnes	22f
	moveal	%d0,%a6
	lea	%pc@(_s_card),%a1
	moveq	#7,%d0
	jsr	%a6@(-552)		/* OpenLibrary("Prometheus.card",7) */
	movel	%d0,%a2@(42)
22:	movel	%a2@(42),%d0
	bnes	23f
	clrl	%d0
	bras	24f
23:	moveal	%d0,%a6			/* card base */
	movel	%d2,%d0			/* size */
	jsr	%a6@(-42)		/* card: AllocDMABuffer */
24:	moveml	%sp@+,%d2/%a2/%a6
	rts

/* ==== 0x930 Prm_FreeDMABuffer(a0=mem,d0=size) ==================== */
_freedma:
	moveml	%d2-%d3/%a2/%a6,%sp@-
	moveal	%a6,%a2			/* lib */
	movel	%a0,%d2			/* mem */
	movel	%d0,%d3			/* size */
	movel	%a2@(34),%d0		/* SysBase */
	tstl	%a2@(42)
	bnes	25f
	moveal	%d0,%a6
	lea	%pc@(_s_card),%a1
	moveq	#7,%d0
	jsr	%a6@(-552)		/* OpenLibrary */
	movel	%d0,%a2@(42)
25:	movel	%a2@(42),%d0
	beqs	26f
	moveal	%d0,%a6
	moveal	%d2,%a0			/* mem */
	movel	%d3,%d0			/* size */
	jsr	%a6@(-48)		/* card: FreeDMABuffer */
26:	moveml	%sp@+,%d2-%d3/%a2/%a6
	rts

/* ==== 0x96a Prm_GetPhysicalAddress(d0=vaddr) =====================
 * returns vaddr & 0x1fffffff if inside [board+0x100000,board+0x1fffffff]
 * else 0.
 */
_getphys:
	movel	%a6,%sp@-
	movel	%d0,%d1			/* vaddr */
	moveal	%a6@(54),%a0		/* boardaddr */
	movel	%a0,%d0
	addil	#1048576,%d0		/* board+0x100000 */
	cmpl	%d1,%d0
	bhis	27f			/* below window -> 0 */
	addil	#535822335,%d0		/* board+0x1fffffff */
	cmpl	%d1,%d0
	bccs	28f			/* inside window */
27:	clrl	%d0
	bras	29f
28:	movel	%d1,%d0
	andil	#536870911,%d0		/* & 0x1fffffff */
29:	moveal	%sp@+,%a6
	rts

/* ==== hunk1 DATA: function table ================================ */
	.data
_functab:
	.long	_open			/* -6   h0+0x5c6 */
	.long	_close			/* -12  h0+0x5d8 */
	.long	_expunge		/* -18  h0+0x5fe */
	.long	_extfunc		/* -24  h0+0x66e */
	.long	_findboard		/* -30  h0+0x674 */
	.long	_getattrs		/* -36  h0+0x6e2 */
	.long	_rdlong			/* -42  h0+0x748 */
	.long	_rdword			/* -48  h0+0x76e */
	.long	_rdbyte			/* -54  h0+0x79a */
	.long	_wrlong			/* -60  h0+0x7c6 */
	.long	_wrword			/* -66  h0+0x7e6 */
	.long	_wrbyte			/* -72  h0+0x806 */
	.long	_setattrs		/* -78  h0+0x82e */
	.long	_addint			/* -84  h0+0x8ac */
	.long	_remint			/* -90  h0+0x8ca */
	.long	_allocdma		/* -96  h0+0x8f6 */
	.long	_freedma		/* -102 h0+0x930 */
	.long	_getphys		/* -108 h0+0x96a */
	.long	-1			/* MakeLibrary table terminator */
