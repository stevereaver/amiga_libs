* script.library 0.4 -- hunk 0 (CODE), byte-identical transcription.
*
* AUTOINIT RomTag; InitTable in hunk1 (DATA), functab + strings in
* hunk2 (CODE).  The library keeps a pooled, named key/value list per
* context and wraps several private rexxsyslib.library vectors.  The
* calling convention is vbcc-style: public vectors take a0/a1 and a2
* (the a2 register is a live argument -- see vec -30 strlen on a2).
*
* Private data @ lib+48 is a copy of the DATA hunk's first 20 bytes
* (dsize/functab/datatab/initfn) followed by SysBase and libbase.

	.text
	.globl	start,_H0

start:						/* 0x00 -- vector -24 target */
_H0:
	moveq	#0,d0
	rts

* ---- RomTag @ 0x04 ----
_rt:
	.short	0x4afc
	dc.l	_rt
	dc.l	_H0+0x1e			/* endskip -> hunk0+0x1e (relocated) */
	dc.b	0x80,0,9,0			/* AUTOINIT, ver 0, NT_LIBRARY, pri 0 */
	dc.l	_H2+0x34			/* name "script.library" */
	dc.l	_H2+0x44			/* idstr "script.library 0.4" */
	dc.l	_H1+4				/* InitTable */

	.short	0				/* 0x1e pad */

* ---- 0x20 initfn: a0=seglist, d0=libbase, a6=exec ----
_init:
	subqw	#8,sp
	moveml	d7/a2-a3/a5-a6,sp@-
	moveal	d0,a5			| libbase
	movel	a0,a5@(34)		| seglist
	moveb	#9,a5@(8)		| ln_Type = NT_LIBRARY
	movel	#_H2+52,a5@(10)	| ln_Name -> hunk2+0x34 (reloc imm)
	moveb	#6,a5@(14)		| lib_Flags
	lea	0:l,a1			| literal 0
	movel	a1,d0
	lea	a5@(20),a0
	movew	d0,a0@+			| lib_Version = 0
	lea	4:l,a1			| literal 4
	movel	a1,d0
	movew	d0,a0@+			| lib_Revision = 4
	movel	#_H2+68,a0@+	| lib_IdString -> hunk2+0x44 (reloc imm)
	lea	a5@(48),a3		| private obj
	lea	5:l,a1			| literal 5
	movel	a1,d0
	movel	d0,d1
	asll	#2,d1			| d1 = 20 (copy count)
	movel	a6,sp@(24)		| stash exec a6 in pad
	lea	_H1:l,a1		| a1 = DATA hunk
	moveal	a3,a6			| a6 = lib+48 dest
	.short	0x0c40			| cmpiw prefix -- imm doubles as copy op
_cpinit:
	.short	0x1cd9			| moveb a1@+,a6@+
	subql	#1,d1
	bccs	_cpinit			| copy 20B DATA -> lib+48
	asll	#2,d0			| d0 = 20
	lea	_H1:l,a0
	addal	d0,a0			| a0 = DATA+20
	movel	a0@,d7			| fixup count (0)
	lea	a0@(4),a2		| fixup table
	moveal	sp@(24),a6
	bras	_fixck
_fixlp:
	movel	a3,d0
	addl	a2@+,d0
	movel	a3,d1
	moveal	d0,a0
	addl	d1,a0@			| *(lib+48 + off) += lib+48
	subql	#1,d7
_fixck:
	tstl	d7
	bgts	_fixlp
	moveal	a5,a6
	bsrw	_setbase		| obj+24=SysBase, obj+28=lib
	tstl	d0
	moveal	sp@(24),a6
	beqs	_iretlib		| d0==0 -> return libbase
	moveq	#0,d0
	.short	0x0c40			| cmpiw prefix (dead path)
_iretlib:
	.short	0x200d			| movel a5,d0
	moveml	sp@+,d7/a2-a3/a5-a6
	addqw	#8,sp
	rts

* ---- 0xc4 -6 Open ----
_open:
	subqw	#4,sp
	addqw	#1,a6@(32)
	bclr	#3,a6@(14)
	movel	a6,d0
	addqw	#4,sp
	rts

* ---- 0xd6 -12 Close ----
_close:
	subqw	#4,sp
	movel	d7,sp@-
	moveq	#0,d7
	subqw	#1,a6@(32)
	movel	a6,sp@(4)
	tstw	a6@(32)
	bnes	_clret
	btst	#3,a6@(14)
	beqs	_clret
	bsrw	_expunge
	movel	d0,d7
_clret:
	movel	d7,d0
	movel	sp@+,d7
	addqw	#4,sp
	rts

* ---- 0x100 -18 Expunge ----
_expunge:
	subqw	#4,sp
	moveml	d2/d7/a5-a6,sp@-
	moveal	a6,a5
	moveq	#0,d7
	bset	#3,a5@(14)		| DELEXP
	movel	a6,sp@(16)
	tstw	a5@(32)
	bnes	_expr			| open -> deferred
	moveal	a5,a6
	bsrw	_nullobj
	movel	a5@(34),d7		| seglist
	moveal	a5,a1
	moveal	4:w,a6
	jsr	a6@(-252)		| Remove
	moveq	#0,d0
	movew	a5@(18),d0		| possize
	moveq	#0,d1
	movew	a5@(16),d1		| negsize
	movel	d1,d2
	addl	d0,d2
	moveal	a5,a1
	moveq	#0,d0
	movew	d1,d0
	subal	d0,a1			| alloc base
	movel	d2,d0
	jsr	a6@(-210)		| FreeMem
_expr:
	movel	d7,d0
	moveml	sp@+,d2/d7/a5-a6
	addqw	#4,sp
	rts
	nop

* ---- 0x158 _setbase: obj+24 = SysBase, obj+28 = lib ----
_setbase:
	subqw	#4,sp
	moveml	a4-a6,sp@-
	moveal	a6,a5
	lea	a6@(48),a4
	moveaw	#4,a0
	movel	a0@,a4@(24)		| *4 = SysBase
	movel	a5,a4@(28)
	moveq	#0,d0
	moveml	sp@+,a4-a6
	addqw	#4,sp
	rts

* ---- 0x17a _nullobj: empty (a4=lib+48) ----
_nullobj:
	subqw	#4,sp
	moveml	a4-a6,sp@-
	moveal	a6,a5
	lea	a6@(48),a4
	moveml	sp@+,a4-a6
	addqw	#4,sp
	rts

* ---- 0x18e -30: (a0=ctx, a1=name, a2=ptr) -> d0 status ----
_vec30:
	subqw	#8,sp
	moveml	d7/a2-a6,sp@-
	moveal	a1,a3
	moveal	a0,a5
	lea	a6@(48),a4
	movel	a5,sp@-
	movel	a6,sp@(28)		| pad slot: save a6
	bsrw	_rexxprobe
	addqw	#4,sp
	tstw	d0
	beqs	_v30fail
	moveal	a2,a0			| a2 = caller-supplied arg
1:	tstb	a0@+
	bnes	1b
	subql	#1,a0
	subal	a2,a0			| strlen(a2)
	movel	a0,sp@-			| len
	movel	a2,sp@-
	movel	a3,sp@-
	movel	a5,sp@-
	bsrw	_0x744
	movel	d0,d7
	lea	sp@(16),sp
	movel	d7,d0
	moveq	#10,d1
	cmpl	d1,d0
	beqs	_v30fail
	movel	d7,d0
	bras	_v30out
_v30fail:
	moveal	a5@(124),a0		| ctx->callback (OOB: ctx is 24B!)
	moveal	sp@(24),a6
	movel	a0,sp@(28)
	beqs	_v30r10
	movel	a2,sp@-
	movel	a3,sp@-
	movel	a0,sp@-
	bsrw	_0x472
	lea	sp@(12),sp
	tstl	d0
	beqs	_v30r3
	moveq	#0,d0
	bras	_v30out
_v30r3:
	moveq	#3,d0
	bras	_v30out
_v30r10:
	moveq	#10,d0
_v30out:
	moveml	sp@+,d7/a2-a6
	addqw	#8,sp
	rts

* ---- 0x206 -36: (a0=ctx, a1=name, a2=out) -> d0 status ----
_vec36:
	subqw	#8,sp
	moveml	d7/a2-a6,sp@-
	moveal	a1,a3
	moveal	a0,a5
	lea	a6@(48),a4
	clrl	a2@			| *out = 0
	movel	a2,sp@-
	movel	a3,sp@-
	movel	a5,sp@-
	movel	a6,sp@(36)		| pad slot
	bsrw	_0x6e6
	movel	d0,d7
	lea	sp@(12),sp
	movel	d7,d0
	moveq	#10,d1
	cmpl	d1,d0
	beqs	_v36fail
	movel	d7,d0
	bras	_v36out
_v36fail:
	moveal	a5@(124),a0
	moveal	sp@(24),a6
	movel	a0,sp@(28)
	beqs	_v36r10
	movel	a3,sp@-
	movel	a0,sp@-
	bsrw	_0x652
	movel	d0,a2@			| *out = found data
	addqw	#8,sp
	moveq	#0,d0
	bras	_v36out
_v36r10:
	moveq	#10,d0
_v36out:
	moveml	sp@+,d7/a2-a6
	addqw	#8,sp
	rts

* ---- 0x25e -42: () -> d0 ctx ----
_vec42:
	subqw	#4,sp
	movel	a4,sp@-
	lea	a6@(48),a4
	movel	a6,sp@(4)
	bsrw	_0x274
	moveal	sp@+,a4
	addqw	#4,sp
	rts

* ---- 0x274 _0x274: create ctx (pool + list) ----
_0x274:
	subqw	#4,sp
	moveml	d2/a3/a5-a6,sp@-
	subal	a5,a5
	subal	a3,a3
	movel	a6,sp@(16)
	moveq	#1,d0
	moveq	#64,d1
	lsll	#4,d1			| puddle 1024
	movel	d1,d2			| thresh 1024
	moveal	4:w,a6
	jsr	a6@(-696)		| CreatePool
	moveal	d0,a3			| pool
	moveal	a3,a0
	movel	a0,d0
	moveal	sp@(16),a6
	bnes	_poolok
	moveq	#0,d0
	bras	_poolret
_poolok:
	moveal	a3,a0
	moveq	#24,d0
	moveal	4:w,a6
	jsr	a6@(-708)		| AllocPooled(pool,24)
	moveal	d0,a5			| ctx
	moveal	a5,a0
	movel	a0,d0
	moveal	sp@(16),a6
	bnes	_ctxok
	moveal	a3,a0
	moveal	4:w,a6
	jsr	a6@(-702)		| DeletePool
	moveq	#0,d0
	bras	_poolret
_ctxok:
	lea	a5@(8),a0
	movel	a0,sp@-
	moveal	sp@(20),a6		| lib a6 (pad slot)
	bsrw	_newlistw		| NewList(ctx+8)
	movel	a3,a5@(20)		| ctx+20 = pool
	addqw	#4,sp
	movel	a5,d0
_poolret:
	moveml	sp@+,d2/a3/a5-a6
	addqw	#4,sp
	rts

* ---- 0x2e6 -48: (a0=ctx) destroy ----
_vec48:
	subqw	#4,sp
	moveml	a4-a5,sp@-
	moveal	a0,a5
	lea	a6@(48),a4
	movel	a5,sp@-
	movel	a6,sp@(12)
	bsrw	_0x306
	addqw	#4,sp
	moveml	sp@+,a4-a5
	addqw	#4,sp
	rts

_0x306:
	subqw	#4,sp
	moveml	a5-a6,sp@-
	moveal	sp@(16),a5		| ctx
	movel	a6,sp@(8)
	moveal	a5@(20),a0		| pool
	moveal	4:w,a6
	jsr	a6@(-702)		| DeletePool
	moveml	sp@+,a5-a6
	addqw	#4,sp
	rts

* ---- 0x328 -54: (a0=ctx, a1=cb) set ctx+124 ----
_vec54:
	subqw	#4,sp
	moveml	a3-a5,sp@-
	moveal	a1,a3
	moveal	a0,a5
	lea	a6@(48),a4
	movel	a3,a5@(124)
	moveml	sp@+,a3-a5
	addqw	#4,sp
	rts

* ---- 0x342 -60: (a0=ctx) -> d0 = ctx+124 ----
_vec60:
	subqw	#4,sp
	moveml	a4-a5,sp@-
	moveal	a0,a5
	lea	a6@(48),a4
	moveal	a5@(124),a0
	movel	a0,d0
	moveml	sp@+,a4-a5
	addqw	#4,sp
	rts

* ---- 0x35c -66: (a0=ctx, a1=name, a2=data) add/set entry ----
_vec66:
	subqw	#4,sp
	moveml	a2-a5,sp@-
	moveal	a1,a3
	moveal	a0,a5
	lea	a6@(48),a4
	movel	a2,sp@-			| data
	movel	a3,sp@-			| name
	movel	a5,sp@-			| ctx
	movel	a6,sp@(28)
	bsrw	_0x472
	lea	sp@(12),sp
	tstl	d0
	beqs	_v66r3
	moveq	#0,d0
	bras	_v66out
_v66r3:
	moveq	#3,d0
_v66out:
	moveml	sp@+,a2-a5
	addqw	#4,sp
	rts

* ---- 0x38e -72: (a0=ctx, a1=name, a2=out) find entry ----
_vec72:
	subqw	#4,sp
	moveml	a2-a5,sp@-
	moveal	a1,a3
	moveal	a0,a5
	lea	a6@(48),a4
	movel	a3,sp@-
	movel	a5,sp@-
	movel	a6,sp@(24)
	bsrw	_0x652
	movel	d0,a2@			| *out = data
	addqw	#8,sp
	moveq	#0,d0
	moveml	sp@+,a2-a5
	addqw	#4,sp
	rts
	nop

* ---- 0x3b8 _freewalk: DEAD helper (no caller) ----
_freewalk:
	subqw	#4,sp
	moveml	a2-a3/a5,sp@-
	moveal	sp@(20),a5		| ctx
	moveal	a5@(8),a3		| list head
	moveal	a3,a2
	movel	a6,sp@(12)
_fwl:
	moveal	a3@,a2			| cur->succ
	movel	a2,d0
	beqs	_fwdone
	movel	a3,sp@-
	movel	a5,sp@-
	bsrw	_freenode
	addqw	#8,sp
	moveal	a2,a3
	bras	_fwl
_fwdone:
	moveml	sp@+,a2-a3/a5
	addqw	#4,sp
	rts

* ---- 0x3e8 _freenode: (ctx, node) pooled free ----
_freenode:
	subqw	#4,sp
	moveml	a2-a3/a5-a6,sp@-
	moveal	sp@(28),a3		| node
	moveal	sp@(24),a5		| ctx
	subal	a2,a2
	movel	a6,sp@(16)
	moveal	a3,a1
	moveal	4:w,a6
	jsr	a6@(-252)		| Remove(node)
	moveal	a5@(20),a2		| pool
	moveal	sp@(16),a6
	movel	a3@(8),d0		| node->name
	beqs	_fnm1
	moveal	d0,a0
	movel	a0,d1
1:	tstb	a0@+
	bnes	1b
	subql	#1,a0
	subal	d1,a0
	movel	a0,d0
	addql	#1,d0			| strlen+1
	moveal	d1,a1
	moveal	a2,a0
	moveal	4:w,a6
	jsr	a6@(-714)		| FreePooled
_fnm1:
	moveq	#1,d0
	cmpw	a3@(16),d0		| node->flag == 1?
	moveal	sp@(16),a6
	bnes	_fnfree
	moveal	a3@(12),a0		| node->data
	movel	a0,d0
2:	tstb	a0@+
	bnes	2b
	subql	#1,a0
	subal	d0,a0
	movel	a0,d0
	addql	#1,d0
	moveal	a2,a0
	moveal	a3@(12),a1
	moveal	4:w,a6
	jsr	a6@(-714)		| FreePooled
_fnfree:
	moveal	a2,a0
	moveal	a3,a1
	moveq	#18,d0
	moveal	4:w,a6
	jsr	a6@(-714)		| FreePooled(node,18)
	moveml	sp@+,a2-a3/a5-a6
	addqw	#4,sp
	rts

* ---- 0x472 _0x472: (ctx, name, data) find-or-set node ----
* iter 1 treats the list HEADER as a node: strcmps the bytes at
* lh_TailPred against the search name and checks 'flag' at header+16
* (OOB on a 24B ctx).  All real nodes are still checked -- the extra
* compare is a benign vestige unless node bytes false-match.
_0x472:
	subaw	#20,sp
	moveml	d7/a2-a3/a5-a6,sp@-
	moveal	sp@(52),a2		| p3 data
	moveal	sp@(48),a3		| p2 name
	moveal	sp@(44),a5		| p1 ctx
	clrl	sp@(28)
	movel	a5@(20),sp@(28)		| pool
	moveal	a5@(8),a0		| header
	movel	a0,sp@(32)		| next slot
	movel	a0,sp@(36)		| cur slot
	movel	a6,sp@(20)		| save a6
_wl:
	moveal	sp@(36),a1
	moveal	a1@,a0			| cur->succ
	movel	a0,sp@(32)
	beqw	_wlend			| NULL -> add new
	moveal	a1@(8),a0		| node->name (prev node!)
	moveal	a3,a6			| search name
_cmp1:
	moveb	a0@+,d0
	cmpb	a6@+,d0
	bnes	_cmp1d
	tstb	d0
	bnes	_cmp1
_cmp1d:
	moveal	sp@(20),a6
	bnew	_wlnext			| mismatch -> advance
	moveq	#1,d0
	cmpw	a1@(16),d0		| flag == 1
	bnes	_wlnext
	moveal	a1@(12),a0		| old data
	movel	a0,d0
3:	tstb	a0@+
	bnes	3b
	subql	#1,a0
	subal	d0,a0
	movel	a0,d0
	addql	#1,d0
	movel	a1,sp@(24)		| node slot
	moveal	sp@(28),a0		| pool
	moveal	a1@(12),a1
	moveal	4:w,a6
	jsr	a6@(-714)		| FreePooled old data
	moveal	a2,a0			| new data str
4:	tstb	a0@+
	bnes	4b
	subql	#1,a0
	subal	a2,a0
	movel	a0,d0
	movel	d0,d7
	addql	#1,d7
	moveal	sp@(28),a0		| pool
	movel	d7,d0
	jsr	a6@(-708)		| AllocPooled(len+1)
	moveal	sp@(24),a0		| node
	movel	d0,a0@(12)		| node->data = new
	tstl	d0
	moveal	sp@(20),a6
	bnes	_cpdone
	clrw	a0@(16)			| flag = 0
	movel	a0,sp@-
	movel	a5,sp@-
	bsrw	_freenode
	addqw	#8,sp
	moveq	#0,d0
	braw	_472out
_cpdone:
	moveal	d0,a1
	moveal	a2,a0
	movel	d7,d0
	moveal	4:w,a6
	jsr	a6@(-624)		| CopyMem
	movel	sp@(24),d0		| return node
	braw	_472out
_wlnext:
	moveal	sp@(20),a6
	movel	sp@(32),sp@(36)		| cur = next
	braw	_wl
_wlend:
	moveal	sp@(28),a0		| pool
	moveq	#18,d0
	moveal	4:w,a6
	jsr	a6@(-708)		| AllocPooled node
	movel	d0,sp@(24)
	tstl	d0
	moveal	sp@(20),a6
	bnes	_newnode
	moveq	#0,d0
	braw	_472out
_newnode:
	moveal	a3,a0			| name
5:	tstb	a0@+
	bnes	5b
	subql	#1,a0
	subal	a3,a0
	movel	a0,d1
	movel	d1,d7
	addql	#1,d7
	moveal	sp@(28),a0
	movel	d7,d0
	moveal	4:w,a6
	jsr	a6@(-708)		| AllocPooled name
	moveal	sp@(24),a0
	movel	d0,a0@(8)		| node->name
	tstl	d0
	moveal	sp@(20),a6
	beqs	_wlfree
	moveal	d0,a1
	moveal	a3,a0
	movel	d7,d0
	moveal	4:w,a6
	jsr	a6@(-624)		| CopyMem name
	moveal	a2,a0			| data
6:	tstb	a0@+
	bnes	6b
	subql	#1,a0
	subal	a2,a0
	movel	a0,d0
	movel	d0,d7
	addql	#1,d7
	moveal	sp@(28),a0
	movel	d7,d0
	jsr	a6@(-708)		| AllocPooled data
	moveal	sp@(24),a0
	movel	d0,a0@(12)		| node->data
	tstl	d0
	moveal	sp@(20),a6
	beqs	_wlfree
	moveal	d0,a1
	moveal	a2,a0
	movel	d7,d0
	moveal	4:w,a6
	jsr	a6@(-624)		| CopyMem data
	moveal	sp@(24),a0
	movew	#1,a0@(16)		| flag = 1
	lea	a5@(8),a0		| &list
	moveal	sp@(24),a1		| node
	jsr	a6@(-240)		| AddHead
	movel	sp@(24),d0
	bras	_472out
_wlfree:
	tstl	sp@(24)
	beqs	_wlret0
	moveal	sp@(24),a0
	movel	a0@(8),d0		| node->name
	beqs	_wlfreenode
	moveal	d0,a0
	movel	a0,d1
7:	tstb	a0@+
	bnes	7b
	subql	#1,a0
	subal	d1,a0
	movel	a0,d0
	addql	#1,d0
	moveal	d1,a1
	moveal	sp@(28),a0
	moveal	4:w,a6
	jsr	a6@(-714)		| FreePooled name
_wlfreenode:
	moveal	sp@(28),a0
	moveal	sp@(24),a1
	moveq	#18,d0
	moveal	4:w,a6
	jsr	a6@(-714)		| FreePooled node
_wlret0:
	moveq	#0,d0
_472out:
	moveml	sp@+,d7/a2-a3/a5-a6
	addaw	#20,sp
	rts

* ---- 0x652 _0x652: (ctx, name) -> d0 = node->data ----
* same header-as-node first-iteration quirk.
_0x652:
	subqw	#8,sp
	moveml	a2-a3/a5,sp@-
	moveal	sp@(28),a3		| name
	moveal	sp@(24),a5		| ctx
	moveal	a5@(8),a2		| header
	movel	a2,sp@(16)
	movel	a6,sp@(12)
_652l:
	moveal	a2@,a0			| cur->succ
	movel	a0,sp@(16)
	beqs	_652nf
	moveal	a2@(8),a0		| node->name
	moveal	a3,a1
8:	moveb	a0@+,d0
	cmpb	a1@+,d0
	bnes	9f
	tstb	d0
	bnes	8b
9:	bnes	_652next
	moveq	#1,d0
	cmpw	a2@(16),d0		| flag == 1
	bnes	_652next
	movel	a2@(12),d0		| node->data
	bras	_652out
_652next:
	moveal	sp@(16),a2
	bras	_652l
_652nf:
	moveq	#0,d0
_652out:
	moveml	sp@+,a2-a3/a5
	addqw	#8,sp
	rts

* ---- 0x6a4 _rexxprobe: open rexxsyslib; if arg+24 == its base
*      and arg+20 != 0 -> IsRexxMsg(arg) ----
_rexxprobe:
	moveal	sp@(4),a0		| stack-arg entry
_rxpreg:				/* 0x6a8 -- reg-arg entry */
	moveml	d2/a2/a6,sp@-
	moveal	a0,a2
	moveal	4:l,a6			| SysBase (long-abs form)
	lea	_rxsname,a1		| "rexxsyslib.library" (PC-rel)
	moveq	#0,d0
	jsr	a6@(-552)		| OpenLibrary
	movel	d0,d2
	beqs	_rxpret
	moveal	d0,a1
	jsr	a6@(-414)		| CloseLibrary
	moveq	#0,d0
	cmpl	a2@(24),d2		| arg+24 == rexxsyslib base?
	bnes	_rxpret
	movel	a2@(20),d1		| arg+20 != 0?
	beqs	_rxpret
	moveal	a2,a0
	moveal	d2,a6
	jsr	a6@(-168)		| IsRexxMsg(arg)
_rxpret:
	tstl	d0
	moveml	sp@+,d2/a2/a6
	rts

* ---- 0x6e6 _0x6e6: arg shuffle wrapper ----
_0x6e6:
	moveml	sp@(4),a0-a1		| a0=arg1, a1=arg2
	movel	sp@(12),sp@(4)		| arg3 -> arg1 slot (out ptr)
	bsrs	_0x6fe
	bnes	_6e6done
	moveal	sp@(4),a0		| p3 (out ptr, shuffled)
	movel	a1,a0@			| *out = a1
_6e6done:
	rts

_0x6fe:
	moveml	d2-d3/a2-a6,sp@-
	moveal	a0,a2			| ctx
	moveal	a1,a3			| name
	bsrs	_rxpreg			| probe(ctx)
	beqs	_6fe_r10
	moveal	a2@(24),a6		| ctx+24 = rexxsyslib base
	moveal	a2@(20),a0		| ctx+20 = msg
	jsr	a6@(-108)		| rexxsyslib -108
	moveal	a0,a4
	moveal	a3,a0
	bsrw	_0x7de
	bnes	_6fe_out
	moveal	a1,a2			| node
	movel	d1,d2
	moveal	a4,a0
	movel	d2,d0
	moveq	#0,d1
	jsr	a6@(-72)		| rexxsyslib -72
	moveq	#0,d0
	addql	#8,a1
	tstl	d1
	beqs	_6fe_out
	subal	a1,a1
	bras	_6fe_out
_6fe_r10:
	moveq	#10,d0
_6fe_out:
	tstl	d0
	moveml	sp@+,d2-d3/a2-a6
	rts

* ---- 0x744 _0x744: (ctx, name, ptr, len) two-phase call ----
* Stashes a continuation ptr + save area at msg+252 via _0x896,
* restored by _0x8b6.  Returns 9 when arg4 > 65535.
_0x744:
	moveml	sp@(4),a0-a1		| a0=p1 ctx, a1=p2
	movel	sp@(16),d0		| p4 len
	movel	sp@(12),sp@(4)		| p3 -> arg1 slot
	movel	d0,d1
	movel	sp@(4),d0		| p3
	moveml	d2-d7/a2-a6,sp@-
	lea	sp@(-12),sp		| 12B save area
	moveal	a0,a2			| ctx
	moveal	a1,a3
	moveal	d0,a5			| p3
	movel	d1,d3			| p4 len
	lea	_744_r3,a0		| continuation addr (PC-rel)
	moveal	sp,a1
	bsrw	_0x896			| stash into msg+252
	moveal	a2,a0
	bsrw	_rxpreg			| probe(ctx)
	beqs	_744_r10
	moveal	a2@(24),a6		| rexxsyslib base
	moveq	#9,d0
	cmpil	#65535,d3
	bgts	_744_out		| len > 65535 -> ret 9
	moveal	a2@(20),a0		| msg
	jsr	a6@(-108)		| rexxsyslib -108
	moveal	a0,a4
	moveal	a3,a0
	bsrw	_0x7de
	bnes	_744_out		| status != 0 propagates
	moveal	a1,a2
	movel	d1,d2
	moveal	a4,a0
	movel	d2,d0
	jsr	a6@(-66)		| rexxsyslib -66
	movel	d0,d4
	moveal	a4,a0
	moveal	a5,a1			| p3
	movel	d3,d0			| len
	bsrw	_0x848			| alloc node
	beqs	_744_r3
	moveal	a4,a0
	moveal	d0,a1			| node
	movel	d4,d0
	jsr	a6@(-84)		| rexxsyslib -84
	moveq	#0,d0
	bras	_744_out
_744_r3:
	moveq	#3,d0
	bras	_744_out
_744_r10:
	moveq	#10,d0
_744_out:
	moveal	sp,a0			| save area
	movel	d0,sp@-
	bsrw	_0x8b6			| restore msg+252
	movel	sp@+,d0
	lea	sp@(12),sp
	moveml	sp@+,d2-d7/a2-a6
	rts

* ---- 0x7de _0x7de: node alloc + '.' split + len verify ----
_0x7de:
	moveml	d2-d3/a2-a3,sp@-
	moveq	#0,d2
	moveq	#0,d3
	jsr	a6@(-288)		| rexxsyslib -288
	moveal	a0,a1
	moveal	a4,a0
	bsrs	_0x848			| node a
	moveal	d0,a2
	beqs	_7de_r3
	lea	a2@(8),a1		| node->str
	movew	a2@(4),d0		| len
	movel	a1,d1
10:	cmpib	#46,a1@+		| scan for '.'
	dbeq	d0,10b
	bnes	_7de_vfy		| no dot -> verify a2
	exg	d1,a1			| a1 = str start
	subl	a1,d1			| d1 = pos after dot
	movel	a2,d3			| d3 = node a
	moveal	a4,a0
	movel	d1,d0
	bsrs	_0x848			| node b (prefix)
	moveal	d0,a2
	beqs	_7de_r3
_7de_vfy:
	lea	a2@(8),a0
	jsr	a6@(-102)		| rexxsyslib -102 (strlen)
	cmpw	a2@(4),d1		| stored len == computed?
	beqs	_7de_ck
	moveq	#40,d2
	bras	_7de_ck
_7de_r3:
	moveq	#3,d2
_7de_ck:
	tstl	d2
	beqs	_7de_ret
	moveal	a4,a0
	moveal	a2,a1
	bsrs	_0x87c			| free node a
	moveal	a4,a0
	moveal	d3,a1
	bsrs	_0x87c			| free node b
_7de_ret:
	moveal	a2,a1
	movel	d3,d1
	movel	d2,d0
	moveml	sp@+,d2-d3/a2-a3
	rts

* ---- 0x848 _0x848: (a0=ctx, a1=str, d0=len) pooled-ish node ----
* node: {pad@0, len@4(w), flag@6(b)=2, d0ret@7(b), str@8, nul@8+len}
_0x848:
	moveml	d0/a1,sp@-
	addql	#8,d0
	addql	#1,d0			| len+9
	jsr	a6@(-114)		| rexxsyslib -114 (alloc)
	moveml	sp@+,d0/a1
	beqs	_848null		| alloc fail -> ret a0(0)
	movel	a0,sp@-
	clrl	a0@			| +0..3 = 0
	movew	d0,a0@(4)		| +4 = len
	moveb	#2,a0@(6)		| +6 = 2
	clrb	a0@(8,d0:l)		| +8+len = 0
	addql	#8,a0			| a0 = node->str
	jsr	a6@(-270)		| rexxsyslib -270 (strcpy)
	moveal	sp@+,a0			| node base
	moveb	d0,a0@(7)		| +7 = strcpy result
_848null:
	movel	a0,d0
	rts

* ---- 0x87c _0x87c: (a0=ctx, a1=node) conditional free ----
_0x87c:
	movel	a1,d1
	beqs	_87cret			| NULL -> nop
	moveq	#1,d0
	andb	a1@(6),d0		| flag bit0 set -> keep
	bnes	_87cret
	movew	a1@(4),d0		| len
	addql	#8,d0
	addql	#1,d0			| len+9
	jsr	a6@(-120)		| rexxsyslib -120 (free)
_87cret:
	rts

* ---- 0x896 _0x896: stash (a0,a1) into ctx->msg+252, save old ----
* a2 = ctx; a1 = 12B save area {ctx, oldmsg252[2]}
_0x896:
	movel	a3,sp@-
	moveal	a2@(20),a3		| ctx+20 = msg
	movel	a2,a1@(0:w)	| save ctx
	moveml	a3@(252),d0-d1		| old msg+252 pair
	moveml	a0-a1,a3@(252)		| msg+252 = (a0=cont, a1=area)
	moveml	d0-d1,a1@(4)		| area+4 = old pair
	moveal	sp@+,a3
	rts

* ---- 0x8b6 _0x8b6: restore msg+252 from save area ----
_0x8b6:
	moveal	a0@(0:w),a1		| area -> ctx
	moveal	a1@(20),a1		| ctx+20 = msg
	moveml	a0@(4),d0-d1		| saved pair
	moveml	d0-d1,a1@(252)		| msg+252 = old pair
	rts

* ---- 0x8cc ----
_rxsname:
	.ascii	"rexxsyslib.library\0"
	.byte	0

* ---- 0x8e0 _newlistw: stack-arg NewList ----
_newlistw:
	moveal	sp@(4),a0
	clrl	a0@(4)
	movel	a0,a0@(8)
	addql	#4,a0
	movel	a0,a0@-
	rts
	.short	0			| tail pad
