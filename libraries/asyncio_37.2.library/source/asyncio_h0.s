/* asyncio.library 37.2 -- Martin Taillefer / Magnus Holmgren (5.1.96)
 * Async double-buffered packet I/O for files (asynchronous dos packets).
 *
 * UNUSUAL layout: the MakeLibrary function table sits BEFORE the
 * RomTag inside CODE hunk 0.  InitTable is a 4-long record
 * (dsize=0x22 = base Library only, functab->h0+4, datatab=0,
 * initfn->h0+0xf2).  Hunk 1 is a 20-byte BSS block of globals,
 * reached through `lea 0:l,a4' (RELOC32 -> hunk1).
 *
 * Globals (hunk1): +0 libbase, +4 execbase, +8 UtilityBase,
 *                 +12 DOSBase, +16 seglist.
 *
 * Vectors: -6 Open, -12 Close, -18 Expunge, -24 null stub (h0+0),
 *   -30 OpenAsync, -36 OpenAsyncFromFH, -42 CloseAsync,
 *   -48 SeekAsync, -54 ReadAsync, -60 WriteAsync,
 *   -66 ReadCharAsync, -72 WriteCharAsync.
 */

	.globl	_nullvec,_ftab,_initfn,_open,_close,_expunge
	.globl	_vec30,_vec36,_vec42,_vec48,_vec54,_vec60,_vec66,_vec72
	.globl	_bsx

	.text

/* ==== 0x00 -24 null stub (moveq #0,rts) ========================== */
_nullvec:
	moveq	#0,%d0
	rts

/* ==== 0x04 function table (absolute longs, -1 terminator) ======== */
_ftab:
	.long	_open			/* -6   */
	.long	_close			/* -12  */
	.long	_expunge		/* -18  */
	.long	_nullvec		/* -24  */
	.long	_vec30			/* -30  OpenAsync         */
	.long	_vec36			/* -36  OpenAsyncFromFH   */
	.long	_vec42			/* -42  CloseAsync        */
	.long	_vec48			/* -48  SeekAsync         */
	.long	_vec54			/* -54  ReadAsync         */
	.long	_vec60			/* -60  WriteAsync        */
	.long	_vec66			/* -66  ReadCharAsync     */
	.long	_vec72			/* -72  WriteCharAsync    */
	.long	-1

/* ==== 0x38 InitTable ============================================= */
_init:
	.long	0x22			/* dataSize = sizeof(Library) */
	.long	_ftab
	.long	0			/* no datatab */
	.long	_initfn

/* ==== 0x48 strings + RomTag ====================================== */
_idstr:
	.ascii	"asyncio.library 37.2 (5.1.96)\r\n"
	.byte	0
_libname:
	.ascii	"asyncio.library"
	.byte	0
_RomTag:
	.short	0x4afc
	.long	_RomTag
	.long	_expunge		/* rt_EndSkip -> 0x190 (!) */
	.byte	0x80,37			/* RTF_AUTOINIT, version 37 */
	.byte	9,0			/* NT_LIBRARY, pri 0 */
	.long	_libname
	.long	_idstr
	.long	_init
_s_dos:
	.ascii	"dos.library"
	.byte	0
_s_util:
	.ascii	"utility.library"
	.byte	0

/* ==== 0xae free helper: close libs, free lib node ================ */
/* a0 = lib; uses a4 globals                                        */
_freelib:
	moveml	%d2/%a5-%a6,%sp@-
	moveal	%a0,%a5
	movel	%a4@(12),%d0		/* DOSBase */
	beqs	1f
	moveal	%d0,%a1
	moveal	%a4@(4),%a6		/* ExecBase */
	jsr	%a6@(-414)		/* CloseLibrary */
	moveal	%a4@(8),%a1		/* UtilityBase (unguarded!) */
	jsr	%a6@(-414)		/* CloseLibrary */
1:	moveq	#0,%d0
	movew	%a5@(16),%d0		/* lib_NegSize */
	moveq	#0,%d1
	movew	%a5@(18),%d1		/* lib_PosSize */
	moveq	#0,%d2
	movew	%d0,%d2
	moveal	%a5,%a1
	subal	%d0,%a1			/* block = lib - negsize */
	addl	%d1,%d2			/* size  = negsize+possize */
	movel	%d2,%d0
	moveal	%a4@(4),%a6
	jsr	%a6@(-210)		/* FreeMem */
	moveml	%sp@+,%d2/%a5-%a6
	rts

/* ==== 0xf2 initfn: d0=libbase, a0=seglist, a6=SysBase ============ */
_initfn:
	moveml	%a2/%a4-%a6,%sp@-
	.short	0x49f9
	.long	_bsx			/* lea _bss,a4 (globals) */
	movel	%a6,%a4@(4)		/* ExecBase */
	lea	%pc@(_s_dos),%a1
	moveal	%d0,%a5			/* lib */
	moveq	#37,%d0
	moveal	%a0,%a2			/* seglist */
	jsr	%a6@(-552)		/* OldOpenLibrary("dos.library",37) */
	movel	%d0,%a4@(12)		/* DOSBase */
	beqs	2f
	lea	%pc@(_s_util),%a1
	moveq	#37,%d0
	jsr	%a6@(-552)		/* OldOpenLibrary("utility.library",37) */
	movel	%d0,%a4@(8)		/* UtilityBase */
	beqs	2f
	lea	%a5@(8),%a6		/* &lib.ln_Type */
	moveb	#9,%a6@+		/* ln_Type = NT_LIBRARY */
	clrb	%a6@+			/* ln_Pri = 0 */
	lea	%pc@(_libname),%a0
	movel	%a0,%a6@+		/* ln_Name */
	moveb	#6,%a6@+		/* ln_Flags = LIBF_SUMUSED|CHANGED */
	lea	%a5@(20),%a6		/* &lib.lib_Version */
	movew	#37,%a6@+		/* lib_Version = 37 */
	movew	#2,%a6@+		/* lib_Revision = 2 */
	lea	%pc@(_idstr),%a0
	movel	%a0,%a6@+		/* lib_IdString */
	movel	%a2,%a4@(16)		/* seglist */
	.short	0x294d,0x0000		/* movel a5,a4@(0) libbase (force disp) */
	bras	3f
2:	moveal	%a5,%a0
	bsrw	_freelib
	subal	%a5,%a5			/* fail -> NULL */
3:	movel	%a5,%d0
	moveml	%sp@+,%a2/%a4-%a6
	rts

/* ==== 0x164 Open ================================================= */
_open:
	addqw	#1,%a6@(32)		/* lib_OpenCnt++ */
	bclr	#3,%a6@(14)		/* clear LIBF_DELEXP */
	movel	%a6,%d0
	rts

/* ==== 0x172 Close ================================================ */
_close:
	movew	%a6@(32),%d0
	beqs	4f
	subqw	#1,%a6@(32)		/* lib_OpenCnt-- */
	bnes	6f
4:	btst	#3,%a6@(14)		/* LIBF_DELEXP? */
	beqs	6f
	bsrw	_expunge
	rts
6:	moveq	#0,%d0
	rts

/* ==== 0x190 Expunge ============================================== */
_expunge:
	moveml	%a4-%a6,%sp@-
	moveal	%a6,%a5
	tstw	%a5@(32)		/* lib_OpenCnt */
	.short	0x49f9
	.long	_bsx			/* lea _bss,a4 */
	beqs	7f
	bset	#3,%a5@(14)		/* set LIBF_DELEXP, defer */
	moveq	#0,%d0
	bras	8f
7:	moveal	%a5,%a1
	moveal	%a4@(4),%a6
	jsr	%a6@(-252)		/* Remove */
	moveal	%a5,%a0
	bsrw	_freelib		/* closelibs + FreeMem node */
	movel	%a4@(16),%d0		/* return seglist */
8:	moveml	%sp@+,%a4-%a6
	rts
	nop

/* ==== 0x1c8 -42 CloseAsync(file=a0) ============================== */
/* result = WaitPacket(file);                                       */
/* if (result>=0 && !file->af_ReadMode)                             */
/*     result = Write(fh,buf[curbuf],bufsize-bytesleft);            */
/* if (ownsFH) Close(fh);  FreeVec(file);  return result            */
_vec42:
	moveml	%d2-%d3/%d7/%a4-%a6,%sp@-
	moveal	%a0,%a5
	movel	%a5,%d0
	.short	0x49f9
	.long	_bsx
	beqs	9f			/* file==NULL */
	moveal	%a5,%a0
	bsrw	_waitpkt		/* WaitPacket */
	movel	%d0,%d7
	blts	10f			/* error -> skip flush */
	tstb	%a5@(143)		/* af_ReadMode */
	bnes	10f
	movel	%a5@(16),%d0		/* af_BytesLeft */
	movel	%a5@(20),%d1		/* af_BufferSize */
	cmpl	%d0,%d1
	blss	10f			/* bufsize < bytesleft -> skip */
	subl	%d0,%d1			/* bytes to flush */
	movel	%a5@(134),%d0		/* af_CurrentBuf */
	asll	#2,%d0
	movel	%d1,%d3
	movel	%a5@,%d1		/* af_File */
	movel	%a5@(0x18,%d0:l),%d2	/* af_Buffers[curbuf] */
	moveal	%a4@(12),%a6
	jsr	%a6@(-48)		/* dos Write */
	movel	%d0,%d7
10:	tstb	%a5@(144)		/* owns filehandle? */
	beqs	11f
	movel	%a5@,%d1		/* af_File */
	moveal	%a4@(12),%a6
	jsr	%a6@(-36)		/* dos Close */
11:	moveal	%a5,%a1
	moveal	%a4@(4),%a6
	jsr	%a6@(-690)		/* FreeVec */
	bras	12f
9:	moveq	#44,%d1
	notb	%d1			/* ERROR_INVALID_LOCK (211) */
	moveal	%a4@(12),%a6
	jsr	%a6@(-462)		/* dos SetIoErr */
	moveq	#-1,%d7
12:	movel	%d7,%d0
	moveml	%sp@+,%d2-%d3/%d7/%a4-%a6
	rts

/* ==== 0x240 -30 OpenAsync(name=a0,mode=d0,bufsize=d1) ============ */
/* mode index -> table -> dos Open() accessMode, then worker        */
_vec30:
	moveml	%d2/%d5-%d7/%a3-%a4/%a6,%sp@-
	movel	%d1,%d6			/* bufferSize */
	movel	%d0,%d7			/* mode index */
	movel	%d7,%d2
	addl	%d2,%d2			/* index*2 */
	moveal	%a0,%a1			/* name */
	lea	%pc@(_modetab),%a0
	movew	%a0@(0,%d2:l),%d2	/* dos open mode */
	.short	0x49f9
	.long	_bsx
	moveal	%a4@(12),%a6		/* DOSBase */
	extl	%d2
	movel	%a1,%d1
	jsr	%a6@(-30)		/* dos Open */
	subal	%a3,%a3
	movel	%d0,%d5			/* handle */
	beqs	13f
	pea	0x1:w			/* ownsFH = TRUE */
	movel	%d6,%sp@-		/* bufferSize */
	movel	%d5,%d0			/* handle */
	movel	%d7,%d1			/* mode */
	bsrw	_openworker
	addqw	#8,%sp
	moveal	%d0,%a3
	tstl	%d0
	bnes	13f
	movel	%d5,%d1			/* failed -> close file */
	jsr	%a6@(-36)		/* dos Close */
13:	movel	%a3,%d0
	moveml	%sp@+,%d2/%d5-%d7/%a3-%a4/%a6
	rts

/* ==== 0x292 mode table =========================================== */
_modetab:
	.short	1005			/* MODE_OLDFILE    */
	.short	1006			/* MODE_NEWFILE    */
	.short	1004			/* MODE_READWRITE  */

/* ==== 0x298 shared open worker =================================== */
/* d0 = handle(BPTR), d1 = mode, stackA = bufsize, stackB = ownsFH  */
/* creates AsyncFile, gets device block size, sends first pkt       */
_openworker:
	subaw	#52,%sp
	moveml	%d2-%d7/%a3/%a5-%a6,%sp@-
	lea	%sp@(48),%a0		/* a_infoData (D_S) */
	movel	%sp@(92),%d6		/* bufferSize */
	movel	%d0,%d7			/* handle */
	moveq	#0,%d5			/* lock */
	movel	%a0,%d0
	andiw	#-4,%d0			/* infoData = a0 & ~3 */
	movel	%d1,%sp@(40)		/* save mode */
	moveal	%d0,%a3
	seq	%d0			/* Z left by movel d1: readmode=(mode==0) */
	negb	%d0
	extw	%d0
	extl	%d0
	subal	%a5,%a5			/* file = NULL */
	movel	%d0,%sp@(36)		/* af_ReadMode flag */
	beqs	14f			/* write/append */
	tstl	%d7			/* read mode: lock via DupLockFromFH */
	beqs	16f
	movel	%d7,%d1
	moveal	%a4@(12),%a6
	jsr	%a6@(-372)		/* dos DupLockFromFH */
	movel	%d0,%d5
	bras	16f
14:	subql	#2,%d1			/* mode == MODE_APPEND? */
	bnes	15f
	tstl	%d7
	beqs	15f
	movel	%d7,%d1
	moveq	#0,%d2
	moveq	#1,%d3			/* OFFSET_END */
	moveal	%a4@(12),%a6
	jsr	%a6@(-66)		/* dos Seek */
	tstl	%d0
	bpls	15f
	tstw	%sp@(98)		/* ownsFH? then close on fail */
	beqs	17f
	movel	%d7,%d1
	jsr	%a6@(-36)		/* dos Close */
17:	movel	%d2,%d7			/* handle = NULL */
15:	tstl	%d7
	beqs	16f
	movel	%d7,%d1
	moveal	%a4@(12),%a6
	jsr	%a6@(-384)		/* dos ParentOfFH */
	movel	%d0,%d5			/* lock */
16:	tstl	%d7
	beqw	31f			/* no handle -> return NULL */
	movel	#512,%sp@(84)		/* blockSize = 512 */
	moveq	#64,%d4
	lsll	#4,%d4			/* 1024 */
	tstl	%d5			/* lock? */
	beqs	21f
	movel	%d5,%d1
	movel	%a3,%d2			/* infoData */
	moveal	%a4@(12),%a6
	jsr	%a6@(-114)		/* dos Info */
	tstl	%d0
	beqs	20f
	movel	%a3@(20),%d0		/* id_BytesPerBlock */
	movel	%d0,%d4
	addl	%d4,%d4			/* 2*blockSize */
	addl	%d4,%d6			/* bufsize += 2*bpp - 1 */
	subql	#1,%d6
	movel	%d0,%sp@(84)		/* blockSize = bpp */
	movel	%d6,%d0
	movel	%d4,%d1
	moveal	%a4@(8),%a0		/* UtilityBase */
	jsr	%a0@(-150)		/* SDivMod32 */
	movel	%d4,%d1
	jsr	%a0@(-138)		/* SMult32 */
	movel	%d0,%d6			/* bufsize = quot*2bpp */
20:	movel	%d5,%d1
	jsr	%a6@(-90)		/* dos UnLock */
21:	movel	%d6,%d0			/* AllocVec loop */
	moveq	#94,%d1
	notb	%d1			/* ~94 = 161 */
	addl	%d1,%d0			/* size = bufsize + 161 */
	moveq	#1,%d1			/* MEMF_ANY */
	moveal	%a4@(4),%a6
	jsr	%a6@(-684)		/* AllocVec */
	moveal	%d0,%a5
	tstl	%d0
	bnes	22f
	cmpl	%d4,%d6
	bles	22f			/* buf <= 2*bpp -> give up */
	subl	%d4,%d6			/* shrink by 2*bpp, retry */
	bras	21b
22:	movel	%a5,%d0
	beqw	30f			/* alloc failed */
	lea	%a5@,%a1
	movel	%d7,%a1@+		/* af_File */
	movel	%sp@(36),%d0
	moveb	%d0,%a5@(143)		/* af_ReadMode = (mode==0) */
	movel	%sp@(84),%a1@+		/* af_BlockSize */
	movew	%sp@(98),%d0
	moveb	%d0,%a5@(144)		/* af_OwnsFH */
	asll	#2,%d7			/* BADDR(handle) */
	moveal	%d7,%a3
	movel	%a3@(8),%a1@+		/* af_Handler = fh_Type */
	lsrl	#1,%d6			/* af_BufferSize = bufsize/2 */
	lea	%a5@(20),%a1
	movel	%d6,%a1@+		/* af_BufferSize */
	movel	%a5,%d1
	moveq	#94,%d0
	notb	%d0
	addl	%d0,%d1			/* file + 161 */
	andiw	#-16,%d1		/* align 16 */
	moveal	%d1,%a0
	addal	%d6,%a0			/* buf1 = buf0 + bufsize */
	movel	%d1,%a1@+		/* af_Buffers[0] */
	movel	%a0,%a1@+		/* af_Buffers[1] */
	lea	%a5@(134),%a1
	clrl	%a1@+			/* af_CurrentBuf = 0 */
	clrl	%a1@+			/* af_SeekOffset = 0 */
	clrb	%a1@+			/* af_PacketPending = FALSE */
	lea	%a5@(124),%a0		/* &mp_MsgList.lh_Tail */
	lea	%a5@(120),%a1		/* &lh_Head */
	movel	%a0,%a1@+		/* lh_Head = &lh_Tail */
	clrl	%a1@+			/* lh_Tail = NULL */
	lea	%a5@(120),%a0
	movel	%a0,%a1@+		/* lh_TailPred = &lh_Head */
	moveq	#4,%d0
	moveb	%d0,%a5@(108)		/* mp_Node.ln_Type = NT_MSGPORT */
	lea	%a5@(110),%a0		/* &ln_Pri/ln_Name */
	clrl	%a0@+			/* ln_Pri+ln_Name = 0 */
	moveb	#2,%a0@+		/* mp_Flags = PA_IGNORE */
	moveb	%d0,%a0@+		/* mp_SigBit = SIGB_SINGLE (4) */
	subal	%a1,%a1
	moveal	%a4@(4),%a6
	jsr	%a6@(-294)		/* FindTask(NULL) */
	movel	%d0,%a5@(116)		/* mp_SigTask */
	lea	%a5@(32),%a0		/* &sp_Msg */
	movel	%a0,%a5@(52)		/* dp_Link = &sp_Msg */
	movel	%a3@(36),%a5@(72)	/* dp_Arg1 = fh_Arg1 */
	movel	%a5@(20),%a5@(80)	/* dp_Arg3 = af_BufferSize */
	clrl	%a5@(64)		/* dp_Res1 = 0 */
	clrl	%a5@(68)		/* dp_Res2 = 0 */
	lea	%a5@(52),%a0
	movel	%a0,%a5@(42)		/* mn_Node.ln_Name = &sp_Pkt */
	moveb	#5,%a5@(40)		/* mn_Node.ln_Type = NT_MESSAGE */
	movew	#68,%a5@(50)		/* mn_Length = 68 */
	tstl	%sp@(40)		/* mode == MODE_READ? */
	bnes	29f
	moveq	#82,%d0			/* 'R' = ACTION_READ */
	movel	%d0,%a5@(60)		/* dp_Type */
	clrl	%a5@(16)		/* af_BytesLeft = 0 */
	movel	%a5@(28),%a5@(12)	/* af_Offset = af_Buffers[1] */
	tstl	%a5@(8)			/* af_Handler? */
	beqs	31f
	moveal	%a5,%a0
	moveal	%a0@(24),%a1		/* af_Buffers[0] */
	bsrw	_sendpkt		/* SendPacket */
	bras	31f
29:	moveq	#87,%d0			/* 'W' = ACTION_WRITE */
	movel	%d0,%a5@(60)		/* dp_Type */
	movel	%a5@(20),%a5@(16)	/* af_BytesLeft = af_BufferSize */
	movel	%a5@(24),%a5@(12)	/* af_Offset = af_Buffers[0] */
	bras	31f
30:	tstw	%sp@(98)		/* ownsFH? */
	beqs	31f
	movel	%d7,%d1
	moveal	%a4@(12),%a6
	jsr	%a6@(-36)		/* dos Close */
31:	movel	%a5,%d0
	moveml	%sp@+,%d2-%d7/%a3/%a5-%a6
	addaw	#52,%sp
	rts

/* ==== 0x488 -36 OpenAsyncFromFH(fh=a0,mode=d0,bufsize=d1) ======== */
_vec36:
	moveml	%d5/%a4,%sp@-
	movel	%d1,%d5
	movel	%d0,%d1			/* mode */
	movel	%a0,%d0			/* filehandle */
	.short	0x49f9
	.long	_bsx
	clrl	%sp@-			/* ownsFH = FALSE */
	movel	%d5,%sp@-		/* bufferSize */
	bsrw	_openworker
	addqw	#8,%sp
	moveml	%sp@+,%d5/%a4
	rts

/* ==== 0x4a8 -54 ReadAsync(numBytes=d0,file=a0,buffer=a1) ========= */
_vec54:
	subqw	#4,%sp
	moveml	%d5-%d7/%a3-%a6,%sp@-
	movel	%d0,%d7			/* numBytes */
	moveq	#0,%d6			/* totalBytes */
	moveal	%a1,%a3			/* buffer */
	moveal	%a0,%a5			/* file */
	.short	0x49f9
	.long	_bsx
	braw	35f
32:	moveal	%a5@(12),%a0		/* af_Offset */
	moveal	%a3,%a1
	movel	%a5@(16),%d0		/* af_BytesLeft */
	moveal	%a4@(4),%a6
	jsr	%a6@(-624)		/* CopyMem */
	movel	%a5@(16),%d0
	subl	%d0,%d7			/* numBytes -= left */
	addl	%d0,%d6			/* total += left */
	clrl	%a5@(16)		/* af_BytesLeft = 0 */
	moveal	%a5,%a0
	addal	%d0,%a3			/* buffer += left */
	bsrw	_waitpkt		/* WaitPacket */
	movel	%d0,%d5			/* bytesArrived */
	bgts	33f
	tstl	%d5
	bnes	34f
	movel	%d6,%d0			/* EOF -> return total */
	bras	36f
34:	moveq	#-1,%d0			/* error -> -1 */
	bras	36f
33:	movel	%a5@(134),%d1		/* af_CurrentBuf */
	asll	#2,%d1
	moveal	%a5,%a0
	subal	%d1,%a0			/* file - curbuf*4 */
	movel	%a0,%sp@(28)
	moveal	%sp@(28),%a1
	moveal	%a1@(28),%a1		/* af_Buffers[1-curbuf] */
	moveal	%a5,%a0
	bsrw	_sendpkt		/* SendPacket */
	movel	%a5@(138),%d0		/* af_SeekOffset */
	cmpl	%d5,%d0
	blss	37f
	movel	%d5,%a5@(138)		/* clamp to bytesArrived */
37:	lea	%a5@(134),%a6
	movel	%a6@+,%d1		/* af_CurrentBuf (a6->138) */
	asll	#2,%d1
	moveal	%a5,%a0
	addal	%d1,%a0
	moveal	%a0@(24),%a1		/* af_Buffers[curbuf] */
	movel	%a6@,%d1		/* af_SeekOffset */
	addal	%d1,%a1			/* + seekoffset */
	movel	%a1,%a5@(12)		/* af_Offset */
	moveq	#1,%d0
	lea	%a5@(134),%a1
	subl	%a1@,%d0		/* 1 - curbuf */
	movel	%d0,%a1@+		/* af_CurrentBuf = 1-curbuf */
	subl	%a6@+,%d5		/* arrived -= seekoffset */
	movel	%d5,%a5@(16)		/* af_BytesLeft */
	clrl	%a1@+			/* af_SeekOffset = 0 */
35:	cmpl	%a5@(16),%d7		/* numBytes > bytesLeft? */
	bgtw	32b
	moveal	%a5@(12),%a0		/* af_Offset */
	moveal	%a3,%a1
	movel	%d7,%d0
	moveal	%a4@(4),%a6
	jsr	%a6@(-624)		/* CopyMem */
	subl	%d7,%a5@(16)		/* bytesLeft -= numBytes */
	addl	%d7,%a5@(12)		/* offset += numBytes */
	movel	%d6,%d0
	addl	%d7,%d0			/* total + numBytes */
36:	moveml	%sp@+,%d5-%d7/%a3-%a6
	addqw	#4,%sp
	rts

/* ==== 0x574 -66 ReadCharAsync(file=a0) =========================== */
_vec66:
	subqw	#4,%sp
	movel	%a4,%sp@-
	moveal	%a0,%a1			/* file */
	movel	%a1@(16),%d0		/* af_BytesLeft */
	.short	0x49f9
	.long	_bsx
	beqs	40f			/* empty -> ReadAsync path */
	moveal	%a1@(12),%a0		/* af_Offset */
	moveb	%a0@,%d1
	moveb	%d1,%sp@(7)
	subql	#1,%a1@(16)		/* bytesLeft-- */
	addql	#1,%a1@(12)		/* offset++ */
	moveq	#0,%d0
	moveb	%d1,%d0			/* return char */
	bras	41f
40:	moveal	%a1,%a0			/* file */
	lea	%sp@(7),%a1		/* &ch */
	moveq	#1,%d0
	bsrw	_vec54			/* ReadAsync(file,&ch,1) */
	tstl	%d0
	bles	42f			/* <=0 -> 'moveq #-1,d0' inside cmpiw */
	moveq	#0,%d0
	moveb	%sp@(7),%d0		/* return char */
	.short	0x0c40			/* cmpiw #0x70ff,d0 (branch lands mid-insn) */
42:	.short	0x70ff			/* == moveq #-1,d0 */
41:	moveal	%sp@+,%a4
	addqw	#4,%sp
	rts
	nop

/* ==== 0x5c0 RecordSyncFailure(file=a0) =========================== */
_recsync:
	moveml	%a5-%a6,%sp@-
	moveal	%a0,%a5
	moveq	#-1,%d0
	movel	%d0,%a5@(64)		/* dp_Res1 = -1 */
	moveal	%a4@(12),%a6
	jsr	%a6@(-132)		/* dos IoErr */
	movel	%d0,%a5@(68)		/* dp_Res2 = IoErr() */
	moveml	%sp@+,%a5-%a6
	rts
	nop

/* ==== 0x5e0 RequeuePacket(file=a0) =============================== */
_requeue:
	moveml	%a5-%a6,%sp@-
	moveal	%a0,%a5
	lea	%a5@(120),%a0		/* &mp_MsgList */
	lea	%a5@(32),%a1		/* &sp_Msg.mn_Node */
	moveal	%a4@(4),%a6
	jsr	%a6@(-240)		/* AddHead */
	moveb	#1,%a5@(142)		/* af_PacketPending = TRUE */
	moveml	%sp@+,%a5-%a6
	rts
	nop

/* ==== 0x604 -48 SeekAsync(file=a0,position=d0,mode=d1) =========== */
_vec48:
	subaw	#276,%sp
	moveml	%d2-%d7/%a3-%a6,%sp@-
	moveal	%a0,%a5			/* file */
	lea	%sp@(56),%a0		/* a_fib (D_S) */
	movel	%d1,%d5			/* mode */
	movel	%d0,%d4			/* position */
	movel	%a0,%d0
	andiw	#-4,%d0
	moveal	%a5,%a0
	.short	0x49f9
	.long	_bsx
	moveal	%d0,%a3			/* fib */
	bsrw	_waitpkt		/* WaitPacket */
	moveml	%d0,%sp@(40)		/* bytesArrived */
	movel	%d0,%d7
	bges	50f
	moveq	#-1,%d0
	braw	599f			/* error */
50:	tstb	%a5@(143)		/* af_ReadMode */
	beqw	56f			/* write path */
	movel	%a5@,%d1		/* af_File */
	moveq	#0,%d2
	movel	%d2,%d3			/* OFFSET_CURRENT */
	moveal	%a4@(12),%a6
	jsr	%a6@(-66)		/* dos Seek */
	movel	%d0,%d6			/* filePos */
	bges	51f
	moveal	%a5,%a0
	bsrw	_recsync
	moveq	#-1,%d0
	braw	599f
51:	movel	%d6,%d0
	subl	%a5@(16),%d0		/* - af_BytesLeft */
	subl	%d7,%d0			/* - bytesArrived */
	addl	%a5@(138),%d0		/* + af_SeekOffset */
	movel	%d0,%d7			/* current */
	tstl	%d5			/* mode == CURRENT? */
	bnes	52f
	movel	%d7,%d5
	addl	%d4,%d5			/* target = current + position */
	bras	53f
52:	addql	#1,%d5			/* mode == -1 (BEGINNING)? */
	bnes	54f
	movel	%d4,%d5			/* target = position */
	bras	53f
54:	movel	%a5@,%d1		/* af_File */
	movel	%a3,%d2			/* fib */
	moveal	%a4@(12),%a6
	jsr	%a6@(-390)		/* dos ExamineFH */
	tstw	%d0
	bnes	55f
	moveal	%a5,%a0
	bsrw	_recsync
	moveq	#-1,%d0
	braw	599f
55:	movel	%a3@(124),%d5		/* fib_Size */
	addl	%d4,%d5			/* target = size + position */
53:	movel	%a5@(134),%d1		/* af_CurrentBuf */
	asll	#2,%d1
	moveal	%a5,%a0
	subal	%d1,%a0			/* file - curbuf*4 */
	movel	%a5@(12),%d0		/* af_Offset */
	lea	%a0@(4),%a3		/* a5+4-curbuf*4 */
	subl	%a3@(24),%d0		/* offset - buffers[1-curbuf] */
	movel	%d7,%d1
	subl	%d0,%d1			/* minBuf = current - that */
	movel	%d5,%d2
	subl	%d7,%d2			/* diff = target - current */
	cmpl	%d1,%d5
	blts	61f			/* target < minBuf */
	movel	%d7,%d0
	addl	%a5@(16),%d0		/* + af_BytesLeft */
	addl	%sp@(40),%d0		/* + bytesArrived = maxBuf */
	cmpl	%d0,%d5
	blts	60f			/* target < maxBuf */
61:	movel	%d5,%d0			/* seek path */
	movel	%a5@(4),%d1		/* af_BlockSize */
	moveal	%a4@(8),%a0		/* UtilityBase */
	jsr	%a0@(-156)		/* UDivMod32 */
	movel	%a5@(4),%d1
	jsr	%a0@(-144)		/* UMult32 */
	movel	%d0,%d4			/* roundTarget */
	movel	%d4,%d2
	subl	%d6,%d2			/* roundTarget - filePos */
	movel	%a5@,%d1		/* af_File */
	moveq	#0,%d3			/* OFFSET_CURRENT */
	moveal	%a4@(12),%a6
	jsr	%a6@(-66)		/* dos Seek */
	tstl	%d0
	bpls	62f
	moveal	%a5,%a0
	bsrw	_recsync
	moveq	#-1,%d0
	braw	599f
62:	moveal	%a5,%a0
	moveal	%a0@(24),%a1		/* af_Buffers[0] */
	bsrw	_sendpkt		/* SendPacket */
	subl	%d4,%d5			/* target - roundTarget */
	movel	%d5,%a5@(138)		/* af_SeekOffset */
	moveq	#0,%d0
	movel	%d0,%a5@(16)		/* af_BytesLeft = 0 */
	clrl	%a5@(134)		/* af_CurrentBuf = 0 */
	movel	%a5@(28),%a5@(12)	/* af_Offset = af_Buffers[1] */
	braw	59f
60:	cmpl	%d7,%d5			/* target < current? */
	blts	63f
	cmpl	%a5@(16),%d2		/* diff > bytesLeft? */
	bgts	64f
63:	moveal	%a5,%a0
	bsrw	_requeue		/* RequeuePacket */
	subl	%d2,%a5@(16)		/* bytesLeft -= diff */
	addl	%d2,%a5@(12)		/* offset += diff */
	braw	59f
64:	moveal	%a5,%a0
	moveal	%a3@(24),%a1		/* af_Buffers[1-curbuf] */
	bsrw	_sendpkt		/* SendPacket */
	lea	%a5@(134),%a6
	movel	%a6@+,%d1		/* af_CurrentBuf (a6->138) */
	asll	#2,%d1
	subl	%a5@(16),%d2		/* diff -= bytesLeft */
	moveal	%a5,%a0
	addal	%d1,%a0
	moveal	%a0@(24),%a1		/* af_Buffers[curbuf] */
	addl	%a6@,%d2		/* diff += seekOffset */
	addal	%d2,%a1
	movel	%a1,%a5@(12)		/* af_Offset = buf+diff */
	movel	%sp@(40),%d0		/* bytesArrived */
	subl	%d2,%d0
	movel	%d0,%a5@(16)		/* bytesLeft = arrived-diff */
	clrl	%a6@+			/* af_SeekOffset = 0 */
	moveq	#1,%d0
	subl	%a5@(134),%d0
	movel	%d0,%a5@(134)		/* af_CurrentBuf = 1-curbuf */
	bras	59f
56:	movel	%a5@(16),%d0		/* write path: flush */
	movel	%a5@(20),%d1		/* af_BufferSize */
	cmpl	%d0,%d1
	blss	57f			/* bufsize < bytesLeft */
	subl	%d0,%d1			/* bytes to flush */
	movel	%a5@(134),%d0		/* af_CurrentBuf */
	asll	#2,%d0
	movel	%d1,%d3
	movel	%a5@,%d1		/* af_File */
	movel	%a5@(0x18,%d0:l),%d2	/* af_Buffers[curbuf] */
	moveal	%a4@(12),%a6
	jsr	%a6@(-48)		/* dos Write */
	tstl	%d0
	bpls	57f
	moveal	%a5,%a0
	bsrw	_recsync
	moveq	#-1,%d0
	bras	599f
57:	movel	%a5@,%d1		/* af_File */
	movel	%d4,%d2			/* position */
	movel	%d5,%d3			/* mode */
	moveal	%a4@(12),%a6
	jsr	%a6@(-66)		/* dos Seek */
	movel	%d0,%d7			/* current */
	bges	58f
	moveal	%a5,%a0
	bsrw	_recsync
	moveq	#-1,%d0
	bras	599f
58:	movel	%a5@(20),%a5@(16)	/* bytesLeft = bufsize */
	clrl	%a5@(134)		/* af_CurrentBuf = 0 */
	movel	%a5@(24),%a5@(12)	/* offset = buffers[0] */
59:	movel	%d7,%d0
599:	moveml	%sp@+,%d2-%d7/%a3-%a6
	addaw	#276,%sp
	rts
	nop

/* ==== 0x7f4 SendPacket(file=a0,arg2=a1) ========================== */
_sendpkt:
	moveml	%a5-%a6,%sp@-
	moveal	%a0,%a5
	lea	%a5@(100),%a0		/* &af_PacketPort */
	movel	%a0,%a5@(56)		/* dp_Port = &port */
	movel	%a1,%a5@(76)		/* dp_Arg2 = arg2 */
	lea	%a5@(32),%a0		/* &sp_Msg */
	moveal	%a0,%a1
	moveal	%a5@(8),%a0		/* af_Handler */
	moveal	%a4@(4),%a6
	jsr	%a6@(-366)		/* PutMsg */
	moveb	#1,%a5@(142)		/* af_PacketPending = TRUE */
	moveml	%sp@+,%a5-%a6
	rts

/* ==== 0x824 WaitPacket(file=a0) ================================== */
_waitpkt:
	moveml	%d2-%d4/%a2-%a3/%a5-%a6,%sp@-
	moveal	%a0,%a5
	tstb	%a5@(142)		/* af_PacketPending? */
	beqs	72f			/* no -> return last state */
	subal	%a2,%a2
	lea	%a5@(100),%a3		/* &af_PacketPort */
70:	clrb	%a5@(114)		/* mp_Flags = PA_SIGNAL */
	moveal	%a4@(4),%a6
	moveal	%a3,%a0
	jsr	%a6@(-384)		/* WaitPort */
	moveal	%d0,%a1
	jsr	%a6@(-252)		/* Remove */
	moveb	#2,%a5@(114)		/* mp_Flags = PA_IGNORE */
	clrb	%a5@(142)		/* pending = FALSE */
	movel	%a5@(64),%d0		/* dp_Res1 */
	bges	73f			/* ok -> return */
	movel	%a5@(68),%d1		/* dp_Res2 */
	movel	%a5@,%d3		/* af_File */
	movel	%a2,%d4
	moveq	#0,%d2			/* REPORT_STREAM */
	moveal	%a4@(12),%a6
	jsr	%a6@(-480)		/* dos ErrorReport */
	tstl	%d0
	beqs	71f
	moveq	#-1,%d0			/* user cancelled -> -1 */
	bras	73f
71:	tstb	%a5@(143)		/* af_ReadMode? resend */
	beqs	74f
	movel	%a5@(134),%d0		/* af_Buffers[curbuf] */
	bras	75f
74:	moveq	#1,%d0			/* af_Buffers[1-curbuf] */
	subl	%a5@(134),%d0
75:	asll	#2,%d0
	moveal	%a5,%a0
	moveal	%a0@(0x18,%d0:l),%a1
	bsrw	_sendpkt		/* resend packet */
	bras	70b
72:	movel	%a5@(68),%d1		/* not pending: dp_Res2 */
	moveal	%a4@(12),%a6
	jsr	%a6@(-462)		/* dos SetIoErr */
	movel	%a5@(64),%d0		/* return dp_Res1 */
73:	moveml	%sp@+,%d2-%d4/%a2-%a3/%a5-%a6
	rts
	nop

/* ==== 0x8ac -60 WriteAsync(numBytes=d0,file=a0,buffer=a1) ======== */
_vec60:
	moveml	%d6-%d7/%a3-%a6,%sp@-
	moveal	%a0,%a5			/* file */
	movel	%d0,%d7			/* numBytes */
	moveq	#0,%d6			/* totalBytes */
	tstl	%a5@(8)			/* af_Handler? */
	moveal	%a1,%a3			/* buffer */
	.short	0x49f9
	.long	_bsx
	bnes	82f			/* handler -> loop */
	movel	%a5@(24),%a5@(12)	/* NIL: offset = buffers[0] */
	movel	%a5@(20),%a5@(16)	/* bytesLeft = bufsize */
	movel	%d7,%d0			/* pretend all written */
	bras	84f
80:	movel	%a5@(16),%d0		/* loop body */
	beqs	81f
	moveal	%a3,%a0			/* buffer -> offset */
	moveal	%a5@(12),%a1
	moveal	%a4@(4),%a6
	jsr	%a6@(-624)		/* CopyMem */
	movel	%a5@(16),%d0
	subl	%d0,%d7			/* numBytes -= filled */
	addl	%d0,%d6			/* total += filled */
	addal	%d0,%a3			/* buffer += filled */
81:	moveal	%a5,%a0
	bsrw	_waitpkt		/* WaitPacket */
	tstl	%d0
	bpls	83f
	moveq	#-1,%d0
	bras	84f
83:	movel	%a5@(134),%d1		/* af_CurrentBuf */
	asll	#2,%d1
	moveal	%a5,%a0
	moveal	%a0@(0x18,%d1:l),%a1	/* af_Buffers[curbuf] */
	bsrw	_sendpkt		/* SendPacket */
	moveq	#1,%d0
	subl	%a5@(134),%d0		/* 1 - curbuf */
	moveal	%a5,%a0
	movel	%d0,%a5@(134)		/* af_CurrentBuf = 1-curbuf */
	asll	#2,%d0
	addal	%d0,%a0
	movel	%a0@(24),%a5@(12)	/* af_Offset = buffers[1-curbuf] */
	movel	%a5@(20),%a5@(16)	/* bytesLeft = bufsize */
82:	cmpl	%a5@(16),%d7		/* numBytes > bytesLeft? */
	bgts	80b
	moveal	%a3,%a0			/* tail copy */
	moveal	%a5@(12),%a1
	movel	%d7,%d0
	moveal	%a4@(4),%a6
	jsr	%a6@(-624)		/* CopyMem */
	subl	%d7,%a5@(16)		/* bytesLeft -= numBytes */
	addl	%d7,%a5@(12)		/* offset += numBytes */
	movel	%d6,%d0
	addl	%d7,%d0			/* total + numBytes */
84:	moveml	%sp@+,%d6-%d7/%a3-%a6
	rts

/* ==== 0x954 -72 WriteCharAsync(ch=d0,file=a0) ==================== */
_vec72:
	subqw	#4,%sp
	movel	%a4,%sp@-
	moveal	%a0,%a1			/* file */
	movel	%d0,%d1			/* ch */
	movel	%a1@(16),%d0		/* af_BytesLeft */
	.short	0x49f9
	.long	_bsx
	beqs	90f			/* full -> WriteAsync */
	moveal	%a1@(12),%a0		/* af_Offset */
	moveb	%d1,%a0@		/* store char */
	subql	#1,%a1@(16)		/* bytesLeft-- */
	addql	#1,%a1@(12)		/* offset++ */
	moveq	#1,%d0			/* 1 byte written */
	bras	91f
90:	moveb	%d1,%sp@(7)		/* ch on stack */
	moveq	#1,%d0
	moveal	%a1,%a0			/* file */
	lea	%sp@(7),%a1		/* &ch */
	bsrw	_vec60			/* WriteAsync(file,&ch,1) */
91:	moveal	%sp@+,%a4
	addqw	#4,%sp
	rts
