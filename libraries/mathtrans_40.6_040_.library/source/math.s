||||
||||	math.s -- the 17 FFP transcendental vectors of
||||	mathtrans.library 40.6 "for 68040".
||||
||||	Full software implementations (the 68040 FPU has
||||	no fsin/fcos/fatan/fexp/flog10/fpowr hardware):
||||	double-precision polynomial/rational kernels with
||||	argument reduction, Cody-Waite style subtraction,
||||	bit-level IEEE-64 exponent manipulation and an
||||	inline coefficient pool (_ctab.._czero).
||||
||||	Transcribed from the shipped binary; the
||||	0x188..0x177b code+constant region assembles
||||	byte-identical.  PC-relative displacements to
||||	inline immediates/constant pool are emitted as
||||	literals (matching the original encoding).
||||
||||	Public entry points (FFP args in d0, FFP result
||||	in d0; SPSincos stores cos via pointer in d1;
||||	SPPow takes the exponent in d1):
||||	  _SPAtan _SPSin _SPCos _SPTan _SPSincos
||||	  _SPSinh _SPCosh _SPTanh _SPExp _SPLog
||||	  _SPPow _SPSqrt _SPTieee _SPFieee _SPAsin
||||	  _SPAcos _SPLog10
||||
||||	Internal helpers (bsr-reachable only):
||||	  _cos_poly _sin_poly _reduce _sp_floor
||||	  _exp_dbl _exp_sgl _exp_poly _log_core _pow_int
||||
_SPAtan:
	.globl	_SPAtan, _SPSin, _SPCos, _SPTan, _SPSincos
	.globl	_SPSinh, _SPCosh, _SPTanh, _SPExp, _SPLog
	.globl	_SPPow, _SPSqrt, _SPTieee, _SPFieee, _SPAsin
	.globl	_SPAcos, _SPLog10

	.section .text
_SPAtan:
	bsrw	_SPTieee
	fmovemx %fp5-%fp7,sp@-
	fmoves d0,%fp7
	fmoved %fp7,sp@-
	moveml sp@,d0-d1
	fmoved %pc@(0x15d4),%fp0
	fcmpx %fp0,%fp7
	fboge	L1b4
	fnegx %fp7,%fp7
	moveq #-1,d1
	bras	L1b6
	.word	0
L1b4:
	moveq #1,d1
L1b6:
	fcmpd #0x4003504f333f9de6,%fp7
	fbole	L1e8
	fmoved #0x3ff921fb54442d18,%fp6
	fmoved #0xbff0000000000000,%fp1
	fdivx %fp7,%fp1
	fmovex %fp1,%fp7
	bras	L220
L1e8:
	fcmpd #0x3fda827999fcef32,%fp7
	fbole	L21c
	fmoved #0x3fe921fb54442d18,%fp6
	fmovex %fp7,%fp1
	faddd %pc@(0x155c),%fp1
	fsubd %pc@(0x1556),%fp7
	fdivx %fp1,%fp7
	bras	L220
	.word	0
L21c:
	fmovex %fp0,%fp6
L220:
	fmovex %fp7,%fp1
	fmulx %fp7,%fp1
	fmoved #0xbfeae950bafb2603,%fp5
	fmulx %fp1,%fp5
	faddd #0xc021ad5e1388a551,%fp5
	fmulx %fp1,%fp5
	faddd #0xc035d8fdb5c5d17a,%fp5
	fmulx %fp1,%fp5
	faddd #0xc02da9522b93aea4,%fp5
	fmovex %fp1,%fp0
	faddd #0x402efeacd8d15592,%fp0
	fmulx %fp1,%fp0
	faddd #0x404f653433b13ad1,%fp0
	fmulx %fp1,%fp0
	faddd #0x40570f3d922255f2,%fp0
	fmulx %fp1,%fp0
	faddd #0x40463efda0aec31f,%fp0
	fdivx %fp0,%fp5
	fmulx %fp1,%fp5
	fmulx %fp7,%fp5
	faddx %fp7,%fp5
	faddx %fp6,%fp5
	tstw d1
	bges	L2c0
	fnegx %fp5,%fp5
L2c0:
	fmoves %fp5,d0
	addqw #8,sp
	fmovemx sp@+,%fp5-%fp7
	braw	_SPFieee
	.word	0
_SPSin:
	bsrw	_SPTieee
	fmovemx %fp6-%fp7,sp@-
	fmoves d0,%fp0
	movel d7,sp@-
	fmoved %fp0,sp@-
	moveml sp@,d0-d1
	ftstx %fp0
	fbeq	L388
	fboge	L2fc
	fnegx %fp0,%fp7
	moveq #-1,d1
	bras	L302
	.word	0
L2fc:
	fmovex %fp0,%fp7
	moveq #1,d1
L302:
	fmovex %fp7,%fp0
	fmuld #0x3ff45f306dc9c883,%fp0
	bsrw	_sp_floor
	fmovex %fp0,%fp6
	fmuld #0x3fb0000000000000,%fp0
	bsrw	_sp_floor
	fmuld #0x4030000000000000,%fp0
	fmovex %fp6,%fp1
	fsubx %fp0,%fp1
	fmovel %fp1,d7
	btst #0,d7
	beqs	L350
	addql #1,d7
	faddd %pc@(0x141a),%fp6
L350:
	andil #7,d7
	cmpil #3,d7
	bles	L362
	negw d1
	subql #4,d7
L362:
	bsrw	_reduce
	cmpil #1,d7
	beqs	L376
	cmpil #2,d7
	bnes	L37c
L376:
	bsrs	_cos_poly
	bras	L380
	.word	0
L37c:
	bsrw	_sin_poly
L380:
	tstw d1
	bpls	L388
	fnegx %fp0,%fp0
L388:
	fmoves %fp0,d0
	addqw #8,sp
	movel sp@+,d7
	fmovemx sp@+,%fp6-%fp7
	braw	_SPFieee
_cos_poly:
	fmoved #0x3da8ff831ad7c64c,%fp0
	fmulx %fp6,%fp0
	faddd #0xbe21eea7c1e51159,%fp0
	fmulx %fp6,%fp0
	faddd #0x3e927e4f8e06d9a0,%fp0
	fmulx %fp6,%fp0
	faddd #0xbefa01a019ddbcd9,%fp0
	fmulx %fp6,%fp0
	faddd #0x3f56c16c16c15d47,%fp0
	fmulx %fp6,%fp0
	faddd #0xbfa5555555555551,%fp0
	fmulx %fp6,%fp0
	faddd %pc@(0x1364),%fp0
	fmulx %fp0,%fp6
	fmoved %pc@(0x1362),%fp0
	fsubx %fp6,%fp0
	rts
	.word	0
_sin_poly:
	fmoved #0x3de5d8fd1fd19ccd,%fp0
	fmulx %fp6,%fp0
	faddd #0xbe5ae5e5a9291f5d,%fp0
	fmulx %fp6,%fp0
	faddd #0x3ec71de3567d48a1,%fp0
	fmulx %fp6,%fp0
	faddd #0xbf2a01a019bfdf03,%fp0
	fmulx %fp6,%fp0
	faddd #0x3f8111111110f7d0,%fp0
	fmulx %fp6,%fp0
	faddd #0xbfc5555555555548,%fp0
	fmulx %fp6,%fp0
	fmulx %fp7,%fp0
	faddx %fp7,%fp0
	rts
	.word	0
_reduce:
	fmoved #0x3ce8469898cc5170,%fp0
	fmoved #0x3e64442d00000000,%fp1
	fmulx %fp6,%fp0
	fmulx %fp6,%fp1
	fmuld #0x3fe921fb40000000,%fp6
	fsubx %fp6,%fp7
	fsubx %fp1,%fp7
	fsubx %fp0,%fp7
	fmovex %fp7,%fp6
	fmulx %fp7,%fp6
	rts
	.word	0
_SPCos:
	bsrw	_SPTieee
	fmovemx %fp6-%fp7,sp@-
	fmoves d0,%fp7
	movel d7,sp@-
	fmoved %fp7,sp@-
	movel sp@,d0
	moveq #1,d1
	ftstx %fp7
	fbuge	L4e2
	fnegx %fp7,%fp7
L4e2:
	fmovex %fp7,%fp0
	fmuld #0x3ff45f306dc9c883,%fp0
	bsrw	_sp_floor
	fmovex %fp0,%fp6
	fmuld #0x3fb0000000000000,%fp0
	bsrw	_sp_floor
	fmuld #0x4030000000000000,%fp0
	fmovex %fp6,%fp1
	fsubx %fp0,%fp1
	fmovel %fp1,d7
	btst #0,d7
	beqs	L530
	addql #1,d7
	faddd %pc@(0x123a),%fp6
L530:
	andil #7,d7
	cmpil #3,d7
	bles	L542
	negw d1
	subql #4,d7
L542:
	cmpil #1,d7
	bles	L54c
	negw d1
L54c:
	bsrw	_reduce
	cmpil #1,d7
	beqs	L560
	cmpil #2,d7
	bnes	L568
L560:
	bsrw	_sin_poly
	bras	L56c
	.word	0
L568:
	bsrw	_cos_poly
L56c:
	tstw d1
	bpls	L574
	fnegx %fp0,%fp0
L574:
	fmoves %fp0,d0
	addqw #8,sp
	movel sp@+,d7
	fmovemx sp@+,%fp6-%fp7
	braw	_SPFieee
_SPTan:
	bsrw	_SPTieee
	fmovemx %fp6-%fp7,sp@-
	fmoves d0,%fp7
	movel d7,sp@-
	fmoved %fp7,sp@-
	moveml sp@,d0-d1
	fcmpd #0x41d0000000000000,%fp7
	fbole	L5b4
	fmoved %pc@(0x11c6),%fp0
	braw	L6ce
L5b4:
	ftstx %fp7
	fbuge	L5c4
	moveq #-1,d1
	fnegx %fp7,%fp7
	bras	L5c6
L5c4:
	moveq #1,d1
L5c6:
	fmovex %fp7,%fp0
	fmuld #0x3ff45f306dc9c883,%fp0
	bsrw	_sp_floor
	fmovex %fp0,%fp6
	fmuld #0x3fc0000000000000,%fp0
	bsrw	_sp_floor
	fmuld #0x4020000000000000,%fp0
	fmovex %fp6,%fp1
	fsubx %fp0,%fp1
	fmovel %fp1,d7
	btst #0,d7
	beqs	L614
	addql #1,d7
	faddd %pc@(0x1156),%fp6
L614:
	bsrw	_reduce
	fcmpd #0x3d06849b86a12b9a,%fp6
	fbule	L6a8
	fmoved #0xc0c992d8d24f3f38,%fp0
	fmulx %fp6,%fp0
	faddd #0x413199eca5fc9ddd,%fp0
	fmulx %fp6,%fp0
	faddd #0xc1711fead3299176,%fp0
	fmovex %fp6,%fp1
	faddd #0x40cab8a5eeb36572,%fp1
	fmulx %fp6,%fp1
	faddd #0xc13427bc582abc96,%fp1
	fmulx %fp6,%fp1
	faddd #0x4177d98fc2ead8ef,%fp1
	fmulx %fp6,%fp1
	faddd #0xc189afe03cbe5a31,%fp1
	fdivx %fp1,%fp0
	fmulx %fp6,%fp0
	fmulx %fp7,%fp0
	faddx %fp7,%fp0
	bras	L6ac
	.word	0
L6a8:
	fmovex %fp7,%fp0
L6ac:
	btst #1,d7
	beqs	L6c6
	fmovex %fp0,%fp1
	fmoved #0xbff0000000000000,%fp0
	fdivx %fp1,%fp0
L6c6:
	tstw d1
	bpls	L6ce
	fnegx %fp0,%fp0
L6ce:
	fmoves %fp0,d0
	addqw #8,sp
	movel sp@+,d7
	fmovemx sp@+,%fp6-%fp7
	braw	_SPFieee
	.word	0
_SPSincos:
	bsrw	_SPTieee
	moveal d1,a1
	fmovemx %fp6-%fp7,sp@-
	fmoves d0,%fp7
	moveml d6-d7,sp@-
	fmoved %fp7,sp@-
	moveml sp@,d0-d1
	moveq #1,d6
	ftstx %fp7
	fbuge	L70c
	fnegx %fp7,%fp7
	moveq #-1,d1
	bras	L70e
L70c:
	moveq #1,d1
L70e:
	fmovex %fp7,%fp0
	fmuld #0x3ff45f306dc9c883,%fp0
	bsrw	_sp_floor
	fmovex %fp0,%fp6
	fmuld #0x3fb0000000000000,%fp0
	bsrw	_sp_floor
	fmuld #0x4030000000000000,%fp0
	fmovex %fp6,%fp1
	fsubx %fp0,%fp1
	fmovel %fp1,d7
	btst #0,d7
	beqs	L75c
	addql #1,d7
	faddd %pc@(0x100e),%fp6
L75c:
	andil #7,d7
	cmpil #3,d7
	bles	L770
	negw d6
	negw d1
	subql #4,d7
L770:
	cmpil #1,d7
	bles	L77a
	negw d6
L77a:
	bsrw	_reduce
	bsrw	_sin_poly
	fmoved #0x3da8ff831ad7c64c,%fp1
	fmulx %fp6,%fp1
	faddd #0xbe21eea7c1e51159,%fp1
	fmulx %fp6,%fp1
	faddd #0x3e927e4f8e06d9a0,%fp1
	fmulx %fp6,%fp1
	faddd #0xbefa01a019ddbcd9,%fp1
	fmulx %fp6,%fp1
	faddd #0x3f56c16c16c15d47,%fp1
	fmulx %fp6,%fp1
	faddd #0xbfa5555555555551,%fp1
	fmulx %fp6,%fp1
	faddd %pc@(0xf7a),%fp1
	fmulx %fp1,%fp6
	fmoved %pc@(0xf78),%fp7
	fsubx %fp6,%fp7
	cmpil #1,d7
	beqs	L806
	cmpil #2,d7
	bnes	L812
L806:
	fmovex %fp0,%fp6
	fmovex %fp7,%fp0
	fmovex %fp6,%fp7
L812:
	tstw d1
	bpls	L81a
	fnegx %fp0,%fp0
L81a:
	tstw d6
	bpls	L822
	fnegx %fp7,%fp7
L822:
	fmovex %fp7,%fp1
	addqw #8,sp
	movel sp@+,d6
	movel sp@+,d7
	fmovemx sp@+,%fp6-%fp7
	fmoves %fp1,d0
	bsrw	_SPFieee
	movel d0,a1@
	fmoves %fp0,d0
	braw	_SPFieee
	.word	0
_SPSinh:
	bsrw	_SPTieee
	fmovemx %fp6-%fp7,sp@-
	fmoves d0,%fp7
	fmoved %fp7,sp@-
	moveml sp@,d0-d1
	fabsx %fp7,%fp6
	fcmpd #0x40862e42fefa39ef,%fp6
	fbole	L888
	fmoved #0x7ff0000000000000,%fp0
	ftstx %fp7
	fbogt	L884
	fnegx %fp0,%fp0
L884:
	braw	L940
L888:
	fcmpd %pc@(0xedc),%fp6
	fbole	L8c0
	fmoved %fp6,sp@
	bsrw	_exp_dbl
	fmovex %fp0,%fp6
	fmoved %pc@(0xebe),%fp1
	fmulx %fp1,%fp0
	fdivx %fp6,%fp1
	fsubx %fp1,%fp0
	ftstx %fp7
	fboge	L940
	fnegx %fp0,%fp0
	braw	L940
L8c0:
	fmulx %fp6,%fp6
	fmoved #0xbfe9435fe8bb3cd6,%fp0
	fmulx %fp6,%fp0
	faddd #0xc064773a398ff4fe,%fp0
	fmulx %fp6,%fp0
	faddd #0xc0c694b8c71d6182,%fp0
	fmulx %fp6,%fp0
	faddd #0xc115782bdbf6ab05,%fp0
	fmovex %fp6,%fp1
	faddd #0xc0715b6096e96484,%fp1
	fmulx %fp6,%fp1
	faddd #0x40e1a7ba7ed72245,%fp1
	fmulx %fp6,%fp1
	faddd #0xc1401a20e4f90044,%fp1
	fdivx %fp1,%fp0
	fmulx %fp6,%fp0
	fmulx %fp7,%fp0
	faddx %fp7,%fp0
L940:
	fmoves %fp0,d0
	addqw #8,sp
	fmovemx sp@+,%fp6-%fp7
	braw	_SPFieee
	.word	0
_SPCosh:
	bsrw	_SPTieee
	fmoves d0,%fp0
	fmoved %fp0,sp@-
	moveml sp@,d0-d1
	fabsd sp@,%fp0
	fcmpd #0x40862e42fefa39ef,%fp0
	fbole	L984
	fmoved #0x7ff0000000000000,%fp0
	bras	L9a0
	.word	0
L984:
	fmoved %fp0,sp@
	bsrw	_exp_dbl
	fmoved %pc@(0xdd8),%fp1
	fdivx %fp0,%fp1
	faddx %fp1,%fp0
	fmuld %pc@(0xdc2),%fp0
L9a0:
	fmoves %fp0,d0
	addqw #8,sp
	braw	_SPFieee
	.word	0
_SPTanh:
	bsrw	_SPTieee
	fmovemx %fp6-%fp7,sp@-
	fmoves d0,%fp7
	fmoved %fp7,sp@-
	moveml sp@,d0-d1
	fabsx %fp7,%fp6
	fcmpd #0x40762e42fefb1d42,%fp6
	fbole	L9ec
	fmoved %pc@(0xd90),%fp0
	ftstx %fp7
	fboge	L9e6
	fnegx %fp0,%fp0
L9e6:
	braw	Lab0
	.word	0
L9ec:
	fcmpd #0x3fe4000000000000,%fp6
	fbolt	La38
	fmovex %fp6,%fp0
	fmuld %pc@(0xd6c),%fp0
	fmoved %fp0,sp@
	bsrw	_exp_dbl
	fmoved %pc@(0xd56),%fp6
	fmoved %pc@(0xd58),%fp1
	faddx %fp6,%fp0
	fdivx %fp0,%fp1
	fsubx %fp1,%fp6
	fmovex %fp6,%fp0
	ftstx %fp7
	fboge	La36
	fnegx %fp0,%fp0
La36:
	bras	Lab0
La38:
	fmovex %fp7,%fp6
	fmulx %fp7,%fp6
	fmoved #0xbfeedc5baafd6f4b,%fp0
	fmulx %fp6,%fp0
	faddd #0xc058d26a0e26682d,%fp0
	fmulx %fp6,%fp0
	faddd #0xc0993ac030580563,%fp0
	fmovex %fp6,%fp1
	faddd #0x405c33f28a581b86,%fp1
	fmulx %fp6,%fp1
	faddd #0x40a176fa0e5535fa,%fp1
	fmulx %fp6,%fp1
	faddd #0x40b2ec102442040c,%fp1
	fdivx %fp1,%fp0
	fmulx %fp0,%fp6
	fmovex %fp7,%fp0
	fmulx %fp6,%fp0
	faddx %fp7,%fp0
Lab0:
	fmoves %fp0,d0
	addqw #8,sp
	fmovemx sp@+,%fp6-%fp7
	braw	_SPFieee
	.word	0
_SPExp:
	bsrw	_SPTieee
	pea _SPFieee(%pc)
	bras	_exp_sgl
	.word	0
_exp_dbl:
	moveml sp@(4),d0-d1
	fmovemx %fp6-%fp7,sp@-
	moveml d0-d1/d6-d7,sp@-
	fmoved sp@,%fp0
	bras	Laf4
_exp_sgl:
	fmovemx %fp6-%fp7,sp@-
	fmoves d0,%fp0
	moveml d6-d7,sp@-
	fmoved %fp0,sp@-
	moveml sp@,d0-d1
Laf4:
	fcmpd #0x40862e42fefa39ef,%fp0
	fbole	Lb14
	fmoved #0x7fefffffffffffff,%fp0
	braw	Lcbc
Lb14:
	fcmpd #0xc086232bdd7abcd2,%fp0
	fboge	Lb30
	fmoved %pc@(0xc4c),%fp0
	braw	Lcbc
	.word	0
Lb30:
	fmovex %fp0,%fp7
	ftstx %fp7
	fboge	Lb44
	fnegx %fp7,%fp7
	moveq #-1,d6
	bras	Lb46
Lb44:
	moveq #1,d6
Lb46:
	fmovex %fp7,%fp0
	fmuld #0x3ff71547652b82fe,%fp0
	faddd %pc@(0xc06),%fp0
	fmovel %fp0,d7
	ftstx %fp0
	fbuge	Lb74
	fcmpl d7,%fp0
	fbule	Lb7e
	addql #1,d7
	bras	Lb7e
Lb74:
	fcmpl d7,%fp0
	fbuge	Lb7e
	subql #1,d7
Lb7e:
	fmovel d7,%fp1
	fmoved #0x3fe6300000000000,%fp0
	fmulx %fp1,%fp0
	fmuld #0x3f2bd0105c610ca8,%fp1
	fsubx %fp0,%fp7
	faddx %fp1,%fp7
	fmovex %fp7,%fp6
	fmulx %fp7,%fp6
	fmoved #0x3f208a008399b72d,%fp0
	fmulx %fp6,%fp0
	faddd #0x3f9f06e1b1502726,%fp0
	fmulx %fp6,%fp0
	faddd %pc@(0xb96),%fp0
	fmulx %fp0,%fp7
	bsrw	_exp_poly
	fsubx %fp7,%fp0
	fdivx %fp0,%fp7
	fmuld %pc@(0xb88),%fp7
	faddd %pc@(0xb7a),%fp7
	fmoved %fp7,sp@-
	moveal sp,a0
	bras	Lc3c
Lbf8:
	fmoved a0@,%fp7
	fbne	Lc0c
	fmoved %pc@(0xb70),%fp0
	braw	Lca8
	.word	0
Lc0c:
	tstw d7
	bles	Lc18
	fmuld %pc@(0xb5c),%fp7
	subql #1,d7
Lc18:
	tstw d7
	bpls	Lc34
	cmpiw #-53,d7
	bges	Lc2c
	fmoved %pc@(0xb4e),%fp0
	bras	Lca8
	.word	0
Lc2c:
	fmuld %pc@(0xb30),%fp7
	addql #1,d7
Lc34:
	tstw d7
	beqs	Lca8
	fmoved %fp7,a0@
Lc3c:
	movew a0@,d1
	andiw #32752,d1
	asrw #4,d1
	beqs	Lbf8
	addw d7,d1
	cmpiw #2047,d1
	bles	Lc5c
	fmoved #0x40862e42fefa39ef,%fp0
	bras	Lca8
Lc5c:
	cmpiw #1,d1
	bges	Lc94
	cmpiw #-53,d1
	bges	Lc70
	fmoved %pc@(0xb08),%fp0
	bras	Lca8
Lc70:
	movew a0@,d7
	andiw #-32753,d7
	oriw #16,d7
	movew d7,a0@
	moveq #1,d7
	fmoved a0@,%fp0
	bras	Lc8c
Lc84:
	fmuld %pc@(0xad8),%fp0
	addqw #1,d1
Lc8c:
	cmpw d7,d1
	blts	Lc84
	bras	Lca8
	.word	0
Lc94:
	movew a0@,d7
	andiw #-32753,d7
	andiw #2047,d1
	aslw #4,d1
	orw d1,d7
	movew d7,a0@
	fmoved a0@,%fp0
Lca8:
	addql #8,sp
	tstw d6
	bpls	Lcbc
	fmoved %pc@(0xab6),%fp1
	fdivx %fp0,%fp1
	fmovex %fp1,%fp0
Lcbc:
	fmoves %fp0,d0
	addqw #8,sp
	movel sp@+,d6
	movel sp@+,d7
	fmovemx sp@+,%fp6-%fp7
	rts
_exp_poly:
	fmoved #0x3ec92f589857ac41,%fp0
	fmulx %fp6,%fp0
	faddd #0x3f64ae563b72044c,%fp0
	fmulx %fp6,%fp0
	faddd #0x3fcd170dc1a95f1e,%fp0
	fmulx %fp6,%fp0
	faddd %pc@(0xa70),%fp0
	rts
_SPLog:
	bsrw	_SPTieee
	fmovemx %fp5-%fp7,sp@-
	fmoves d0,%fp0
	fmoved %fp0,sp@-
	moveml sp@,d0-d1
	fbogt	Ld2c
	fmoved #0x7fffffffffffffff,%fp6
	bras	Ld2e
	.word	0
Ld2c:
	bsrs	_log_core
Ld2e:
	fmoves %fp6,d0
	addqw #8,sp
	fmovex %fp6,%fp0
	fmovemx sp@+,%fp5-%fp7
	braw	_SPFieee
_log_core:
	fmoved %fp0,sp@-
	movew sp@,d0
	lsrw #4,d0
	andil #2047,d0
	bnes	Ld7a
	ftstx %fp0
	fbeq	Ld88
	fmoved %pc@(0xa14),%fp1
Ld5e:
	fmoved sp@,%fp0
	fmulx %fp1,%fp0
	fmoved %fp0,sp@
	subql #1,d0
	movew sp@,d1
	lsrw #4,d1
	andil #2047,d1
	beqs	Ld5e
	addl d1,d0
Ld7a:
	subil #1022,d0
	andiw #-32753,sp@
	oriw #16352,sp@
Ld88:
	fmoved sp@+,%fp7
	cmpiw #2,d0
	bgts	Ld9a
	cmpiw #-2,d0
	bgew	Le50
Ld9a:
	fmoved %pc@(0x9c2),%fp0
	fmovex %fp7,%fp6
	fsubx %fp0,%fp6
	fcmpd #0x3fe6a09e667f3bcd,%fp7
	fboge	Ldc0
	subql #1,d0
	fmovex %fp6,%fp5
	bras	Ldc8
Ldc0:
	fsubx %fp0,%fp6
	fmovex %fp7,%fp5
Ldc8:
	fmulx %fp0,%fp5
	faddx %fp0,%fp5
	fmovex %fp6,%fp7
	fdivx %fp5,%fp7
	fmovex %fp7,%fp6
	fmulx %fp7,%fp6
	fmoved #0xbfe9443ddc6c0e84,%fp0
	fmulx %fp6,%fp0
	faddd #0x403062fc73027b6b,%fp0
	fmulx %fp6,%fp0
	faddd #0xc050090611222a20,%fp0
	fmovex %fp6,%fp1
	faddd #0xc041d60d43ec6d0a,%fp1
	fmulx %fp6,%fp1
	faddd #0x40738180112ae40e,%fp1
	fmulx %fp6,%fp1
	faddd #0xc0880d8919b33f3b,%fp1
	fdivx %fp1,%fp0
	fmulx %fp0,%fp6
	fmulx %fp7,%fp6
	faddx %fp7,%fp6
	braw	Lf64
Le50:
	fcmpd #0x3fe6a09e667f3bcd,%fp7
	fboge	Le68
	subql #1,d0
	fmuld %pc@(0x90a),%fp7
Le68:
	fsubd %pc@(0x8fc),%fp7
	fmovex %fp7,%fp6
	fmulx %fp7,%fp6
	fmoved #0x3f0809a76a5f974f,%fp0
	fmulx %fp7,%fp0
	faddd #0x3fdfe7eed9795a1a,%fp0
	fmulx %fp7,%fp0
	faddd #0x401a40a2c66c74c9,%fp0
	fmulx %fp7,%fp0
	faddd #0x403dc9a97e3d411d,%fp0
	fmulx %fp7,%fp0
	faddd #0x404e4e6d64ebdcdc,%fp0
	fmulx %fp7,%fp0
	faddd #0x404c5e122519d312,%fp0
	fmulx %fp7,%fp0
	faddd #0x4033e3a589b13130,%fp0
	fmovex %fp7,%fp1
	faddd #0x402e10160dfbd0a2,%fp1
	fmulx %fp7,%fp1
	faddd #0x4054af6d47ae79c7,%fp1
	fmulx %fp7,%fp1
	faddd #0x406b9542a44b455a,%fp1
	fmulx %fp7,%fp1
	faddd #0x40733411298310d7,%fp1
	fmulx %fp7,%fp1
	faddd #0x406ade942a8d3423,%fp1
	fmulx %fp7,%fp1
	faddd #0x404dd5784e89c9c8,%fp1
	fdivx %fp1,%fp0
	fmulx %fp6,%fp0
	fmovex %fp7,%fp5
	fmulx %fp0,%fp5
	fmuld %pc@(0x80a),%fp6
	fsubx %fp6,%fp5
	fmovex %fp7,%fp6
	faddx %fp5,%fp6
Lf64:
	tstl d0
	beqs	Lf90
	fmovel d0,%fp5
	fmoved #0x3f2bd0105c610ca8,%fp0
	fmulx %fp5,%fp0
	fsubx %fp0,%fp6
	fmuld #0x3fe6300000000000,%fp5
	faddx %fp5,%fp6
Lf90:
	rts
	.word	0
_SPPow:
	exg d0,d1
	bsrw	_SPTieee
	exg d0,d1
	bsrw	_SPTieee
	moveml d2-d3,sp@-
	fmovemx %fp4-%fp7,sp@-
	fmoves d0,%fp0
	fmoves d1,%fp1
	moveml d6-d7,sp@-
	fmoved %fp1,sp@-
	fmoved %fp0,sp@-
	moveml sp@(4),d1-d3
	fmovel %fp1,d0
	ftstx %fp1
	fbuge	Lfdc
	fcmpl d0,%fp1
	fbule	Lfe6
	addql #1,d0
	bras	Lfe6
	.word	0
Lfdc:
	fcmpl d0,%fp1
	fbuge	Lfe6
	subql #1,d0
Lfe6:
	fmovel d0,%fp5
	fcmpx %fp1,%fp5
	fbne	L1006
	fabsx %fp5,%fp5
	fcmpd #0x40e0000000000000,%fp5
	fbolt	_pow_int
L1006:
	fmovex %fp1,%fp4
	ftstx %fp0
	fbogt	L1024
	fmoved #0xfff0000000000000,%fp0
	braw	L11f0
	.word	0
L1024:
	bsrw	_log_core
	fmulx %fp6,%fp4
	fcmpd #0x40862e42fefa39ef,%fp4
	fbole	L104c
	fmoved #0x7fefffffffffffff,%fp0
	braw	L11f0
L104c:
	fcmpd #0xc086232bdd7abcd2,%fp4
	fboge	L1068
	fmoved %pc@(0x714),%fp0
	braw	L11f0
	.word	0
L1068:
	ftstx %fp4
	fboge	L1078
	fnegx %fp4,%fp4
	moveq #-1,d6
	bras	L107a
L1078:
	moveq #1,d6
L107a:
	fmovex %fp4,%fp0
	fmuld #0x3ff71547652b82fe,%fp0
	faddd %pc@(0x6d2),%fp0
	fmovel %fp0,d7
	ftstx %fp0
	fbuge	L10a8
	fcmpl d7,%fp0
	fbule	L10b2
	addql #1,d7
	bras	L10b2
L10a8:
	fcmpl d7,%fp0
	fbuge	L10b2
	subql #1,d7
L10b2:
	fmovel d7,%fp1
	fmoved #0x3fe6300000000000,%fp0
	fmulx %fp1,%fp0
	fmuld #0x3f2bd0105c610ca8,%fp1
	fsubx %fp0,%fp4
	faddx %fp1,%fp4
	fmovex %fp4,%fp6
	fmulx %fp4,%fp6
	fmoved #0x3f208a008399b72d,%fp0
	fmulx %fp6,%fp0
	faddd #0x3f9f06e1b1502726,%fp0
	fmulx %fp6,%fp0
	faddd %pc@(0x662),%fp0
	fmulx %fp0,%fp4
	bsrw	_exp_poly
	fsubx %fp4,%fp0
	fdivx %fp0,%fp4
	fmuld %pc@(0x654),%fp4
	faddd %pc@(0x646),%fp4
	fmoved %fp4,sp@-
	moveal sp,a0
	bras	L1170
L112c:
	fmoved a0@,%fp4
	fbne	L1140
	fmoved %pc@(0x63c),%fp0
	braw	L11dc
	.word	0
L1140:
	tstw d7
	bles	L114c
	fmuld %pc@(0x628),%fp4
	subql #1,d7
L114c:
	tstw d7
	bpls	L1168
	cmpiw #-53,d7
	bges	L1160
	fmoved %pc@(0x61a),%fp0
	bras	L11dc
	.word	0
L1160:
	fmuld %pc@(0x5fc),%fp4
	addql #1,d7
L1168:
	tstw d7
	beqs	L11dc
	fmoved %fp4,a0@
L1170:
	movew a0@,d1
	andiw #32752,d1
	asrw #4,d1
	beqs	L112c
	addw d7,d1
	cmpiw #2047,d1
	bles	L1190
	fmoved #0x40862e42fefa39ef,%fp0
	bras	L11dc
L1190:
	cmpiw #1,d1
	bges	L11c8
	cmpiw #-53,d1
	bges	L11a4
	fmoved %pc@(0x5d4),%fp0
	bras	L11dc
L11a4:
	movew a0@,d7
	andiw #-32753,d7
	oriw #16,d7
	movew d7,a0@
	moveq #1,d7
	fmoved a0@,%fp0
	bras	L11c0
L11b8:
	fmuld %pc@(0x5a4),%fp0
	addqw #1,d1
L11c0:
	cmpw d7,d1
	blts	L11b8
	bras	L11dc
	.word	0
L11c8:
	movew a0@,d7
	andiw #-32753,d7
	andiw #2047,d1
	aslw #4,d1
	orw d1,d7
	movew d7,a0@
	fmoved a0@,%fp0
L11dc:
	addql #8,sp
	tstw d6
	bpls	L11f0
	fmoved %pc@(0x582),%fp1
	fdivx %fp0,%fp1
	fmovex %fp1,%fp0
L11f0:
	fmoves %fp0,d0
	addqw #8,sp
	addqw #8,sp
	movel sp@+,d6
	movel sp@+,d7
	fmovemx sp@+,%fp4-%fp7
	movel sp@+,d2
	movel sp@+,d3
	braw	_SPFieee
_pow_int:
	moveml d4-d5,sp@-
	ftstx %fp0
	fbne	L1244
	tstl d0
	bnes	L1224
	fmoved %pc@(0x54c),%fp0
	braw	L13dc
	.word	0
L1224:
	bpls	L1238
	fmoved #0x7ff0000000000000,%fp0
	braw	L13dc
	.word	0
L1238:
	fmoved %pc@(0x538),%fp0
	braw	L13dc
	.word	0
L1244:
	tstl d0
	bnes	L1254
	fmoved %pc@(0x51c),%fp0
	braw	L13dc
	.word	0
L1254:
	ftstx %fp0
	fboge	L1264
	moveq #-1,d7
	fnegx %fp0,%fp0
	bras	L1266
L1264:
	moveq #0,d7
L1266:
	movel d0,d5
	tstl d0
	bpls	L1274
	moveq #-1,d6
	negl d5
	bras	L1276
	.word	0
L1274:
	moveq #0,d6
L1276:
	fmovex %fp0,%fp7
	movel d0,d4
	fmoved %fp0,sp@-
	movew sp@,d0
	lsrw #4,d0
	andil #2047,d0
	bnes	L12b6
	ftstx %fp0
	fbeq	L12c4
	fmoved %pc@(0x4d8),%fp1
L129a:
	fmoved sp@,%fp0
	fmulx %fp1,%fp0
	fmoved %fp0,sp@
	subql #1,d0
	movew sp@,d1
	lsrw #4,d1
	andil #2047,d1
	beqs	L129a
	addl d1,d0
L12b6:
	subil #1022,d0
	andiw #-32753,sp@
	oriw #16352,sp@
L12c4:
	fmoved sp@+,%fp6
	movel d0,d1
	subql #1,d1
	.word	0x4c05,0x1001	| mulul d5,d1
	beqs	L12e2
	cmpil #64,d1
	bgts	L12e2
	cmpil #-64,d1
	bges	L132c
L12e2:
	fmovex %fp6,%fp0
	faddd #0x3fe6a09e667f3bcc,%fp0
	fsubd #0x3fe6a09e667f3bcc,%fp6
	fdivx %fp0,%fp6
	fmuld #0x4007504f333f9de6,%fp6
	fsubd %pc@(0x44e),%fp6
	faddl d0,%fp6
	fmull d4,%fp6
	fmuld #0x3fe62e42fefa39ef,%fp6
	bras	L133c
	.word	0
L132c:
	fmoved #0x3fe62e42fefa39ef,%fp6
	fmull d1,%fp6
L133c:
	fcmpd #0x40862e42fefa39ef,%fp6
	fbole	L135c
	fmoved #0x7ff0000000000000,%fp0
	bras	L13c2
	.word	0
L135c:
	fcmpd #0xc086232bdd7abcd2,%fp6
	fboge	L1374
	fmoved %pc@(0x404),%fp0
	bras	L13dc
L1374:
	fcmpd #0xc0861e42fefa39ef,%fp6
	fboge	L1394
	fmoved %pc@(0x3e0),%fp0
	fdivx %fp7,%fp0
	moveq #0,d6
	fmovex %fp0,%fp7
L1394:
	btst #0,d5
	beqs	L13a0
	fmovex %fp7,%fp0
	bras	L13a8
L13a0:
	fmoved %pc@(0x3c4),%fp0
	moveq #0,d7
L13a8:
	fmovex %fp7,%fp1
	lsrl #1,d5
	bras	L13c0
L13b0:
	fmulx %fp1,%fp1
	btst #0,d5
	beqs	L13be
	fmulx %fp1,%fp0
L13be:
	lsrl #1,d5
L13c0:
	bnes	L13b0
L13c2:
	tstw d7
	beqs	L13ca
	fnegx %fp0,%fp0
L13ca:
	tstw d6
	beqs	L13dc
	fmoved %pc@(0x396),%fp1
	fdivx %fp0,%fp1
	fmovex %fp1,%fp0
L13dc:
	movel sp@+,d4
	movel sp@+,d5
	fmoves %fp0,d0
	addqw #8,sp
	addqw #8,sp
	movel sp@+,d6
	movel sp@+,d7
	fmovemx sp@+,%fp4-%fp7
	movel sp@+,d2
	movel sp@+,d3
	bras	_SPFieee
	.word	0
_SPTieee:
	addl d0,d0
	beqs	L140a
	eorib #-128,d0
	asrb #1,d0
	subib #-126,d0
	swap d0
	roll #7,d0
L140a:
	rts
_SPFieee:
	swap d0
	rorl #7,d0
	eorib #-128,d0
	addb d0,d0
	bvss	L1424
	addqb #5,d0
	bvss	L145c
	eorib #-128,d0
	rorl #1,d0
L1422:
	rts
L1424:
	bccs	L144c
	cmpib #124,d0
	beqs	L1432
	cmpib #126,d0
	bnes	L1440
L1432:
	addib #-123,d0
	rorl #1,d0
	tstb d0
	bnes	L1422
	moveq #0,d0
	rts
L1440:
	andiw #-257,d0
	tstl d0
	beqs	L1422
	moveq #0,d0
	rts
L144c:
	cmpib #-2,d0
	bnes	L145c
	moveq #9,d1
	lsrl d1,d0
	beqs	L145e
	moveq #0,d0
	rts
L145c:
	lslw #8,d0
L145e:
	moveq #-1,d0
	roxrb #1,d0
	orib #2,%ccr
	rts
_SPSqrt:
	bsrs	_SPTieee
	fsqrts d0,%fp0
	fmoves %fp0,d0
	bras	_SPFieee
_SPAsin:
	bsrs	_SPTieee
	pea _SPFieee(%pc)
	bras	L1490
L147c:
	moveml sp@(4),d0-d1
	fmovemx %fp5-%fp7,sp@-
	moveml d0-d1/d7,sp@-
	fmoved sp@,%fp7
	bras	L14a2
L1490:
	fmovemx %fp5-%fp7,sp@-
	fmoves d0,%fp7
	movel d7,sp@-
	fmoved %fp7,sp@-
	moveml sp@,d0-d1
L14a2:
	ftstx %fp7
	fbogt	L14b4
	moveq #-1,d1
	fnegx %fp7,%fp7
	bras	L14b6
	.word	0
L14b4:
	moveq #1,d1
L14b6:
	fcmpd %pc@(0x2ae),%fp7
	fbole	L14d0
	fmoved #0x7fffffffffffffff,%fp0
	braw	L15ee
L14d0:
	fcmpd #0x3e7ad7f29abcaf48,%fp7
	fboge	L14e8
	fmovex %fp7,%fp0
	braw	L15e6
L14e8:
	fcmpd %pc@(0x274),%fp7
	fbole	L1510
	fmoved %pc@(0x26a),%fp0
	fmovex %fp0,%fp5
	fsubx %fp7,%fp5
	faddx %fp0,%fp5
	fmulx %fp0,%fp5
	fsqrtx %fp5,%fp6
	moveq #1,d7
	bras	L151e
L1510:
	fmovex %fp7,%fp6
	fmovex %fp7,%fp5
	moveq #0,d7
	fmulx %fp7,%fp5
L151e:
	fmoved #0xbfe64c5ee8bc95e7,%fp1
	fmulx %fp5,%fp1
	faddd #0x402451d50e312167,%fp1
	fmulx %fp5,%fp1
	faddd #0xc043ddf63d5cb650,%fp1
	fmulx %fp5,%fp1
	faddd #0x404ca546840a8021,%fp1
	fmulx %fp5,%fp1
	faddd #0xc03b6a31a585d71d,%fp1
	fmovex %fp5,%fp0
	faddd #0xc037d63a2166371c,%fp0
	fmulx %fp5,%fp0
	faddd #0x4062e30ad5e8d5ce,%fp0
	fmulx %fp5,%fp0
	faddd #0xc077e571866170dd,%fp0
	fmulx %fp5,%fp0
	faddd #0x407a1c46dd5cdcf9,%fp0
	fmulx %fp5,%fp0
	faddd #0xc0648fa53c246158,%fp0
	fdivx %fp0,%fp1
	fmulx %fp5,%fp1
	fmovex %fp6,%fp0
	fmulx %fp1,%fp0
	faddx %fp6,%fp0
	tstw d7
	beqs	L15e6
	faddx %fp0,%fp0
	fnegx %fp0,%fp0
	faddd #0x3ff921fb54442d18,%fp0
L15e6:
	tstw d1
	bpls	L15ee
	fnegx %fp0,%fp0
L15ee:
	fmoves %fp0,d0
	addqw #8,sp
	movel sp@+,d7
	fmovemx sp@+,%fp5-%fp7
	rts
_SPAcos:
	bsrw	_SPTieee
	fmoves d0,%fp0
	fmoved %fp0,sp@-
	moveml sp@,d0-d1
	fcmpd #0xbff0000000000000,%fp0
	fbult	L1666
	fcmpd #0xbfe0000000000000,%fp0
	fboge	L165c
	faddd %pc@(0x138),%fp0
	fmuld %pc@(0x12a),%fp0
	fsqrtx %fp0,%fp0
	fmoved %fp0,sp@
	bsrw	L147c
	fmuld %pc@(0x128),%fp0
	fnegx %fp0,%fp0
	faddd #0x400921fb54442d18,%fp0
	bras	L16b8
L165c:
	fcmpd %pc@(0x108),%fp0
	fbole	L1670
L1666:
	fmoved %pc@(0x10a),%fp0
	bras	L16b8
	.word	0
L1670:
	fcmpd %pc@(0xec),%fp0
	fbole	L16a0
	fnegx %fp0,%fp0
	faddd %pc@(0xe6),%fp0
	fmuld %pc@(0xd8),%fp0
	fsqrtx %fp0,%fp0
	fmoved %fp0,sp@
	bsrw	L147c
	fmuld %pc@(0xd6),%fp0
	bras	L16b8
	.word	0
L16a0:
	fmoved %fp0,sp@
	bsrw	L147c
	fnegx %fp0,%fp0
	faddd #0x3ff921fb54442d18,%fp0
L16b8:
	fmoves %fp0,d0
	addqw #8,sp
	braw	_SPFieee
	.word	0
_SPLog10:
	bsrw	_SPLog
	fmuld #0x3fdbcb7b1526e50e,%fp0
	fmoves %fp0,d0
	braw	_SPFieee
_sp_floor:
	moveml d0-d1,sp@-
	fmoved %fp0,sp@-
	moveal sp,a0
	movew a0@,d0
	lsrw #4,d0
	andiw #2047,d0
	subiw #1023,d0
	addqw #6,a0
	bges	L1714
	ftstx %fp0
	fboge	L170c
	fmoved #0xbff0000000000000,%fp0
	bras	L1758
L170c:
	fmoved %pc@(0x64),%fp0
	bras	L1758
L1714:
	moveq #52,d1
	subw d0,d1
	moveq #16,d0
	bras	L1722
L171c:
	clrw a0@
	subql #2,a0
	subw d0,d1
L1722:
	cmpw d0,d1
	bges	L171c
	tstl d1
	bles	L1730
	moveq #-1,d0
	aslw d1,d0
	andw d0,a0@
L1730:
	ftstx %fp0
	fboge	L174c
	fcmpd a0@,%fp0
	fbeq	L174c
	fmoved a0@,%fp0
	fsubd %pc@(0x20),%fp0
	bras	L1758
L174c:
	fmoved sp@+,%fp0
	movel sp@+,d0
	movel sp@+,d1
	rts
	.word	0
L1758:
	addql #8,sp
	movel sp@+,d0
	movel sp@+,d1
	rts
_ctab:
_chalf:
	.quad	0x3fe0000000000000
_cone:
	.quad	0x3ff0000000000000
_ctwo:
	.quad	0x4000000000000000
_czero:
	.long	0x00000000
