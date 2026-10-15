	.text
	.short 0x7000	/* moveq #0,d0 */
	rts
	illegal
	.short 0x0000,0x0004	/* orib #4,d0 */
	.short 0x0000,0x007a	/* orib #122,d0 */
	orb a0@(2304),d0
	.short 0x0000,0x001e	/* orib #30,d0 */
	.short 0x0000,0x0036	/* orib #54,d0 */
	.short 0x0000,0x007a	/* orib #122,d0 */
	blts L81
	.short 0x7468	/* moveq #104,d2 */
	bvss L89
	bcss L8b
	bccs L97
	.short 0x7562
	bhis L8d
	.short 0x732e
	bges L99
	bhis La4
	bsrs La6
	.short 0x7900
	blts L99
	.short 0x7468	/* moveq #104,d2 */
	bvss La1
	bcss La3
	bccs Laf
	.short 0x7562
	bhis La5
	.short 0x7320
	.short 0x3430,0x2e36	/* "40.6" */
	movel a0@(14126),d0
	movew a6@(14645),d2
	movel a0@-,a4@-
	bnes Lc5
	.short 0x7220	/* moveq #32,d1 */
	movew 0x3034,d3
	movew a5,d0
	.short 0x0a00,0x2863	/* eorib #99,d0 */
	movel a0@-,a4@-
	movew 0x39352062,a0@-
	.short 0x7920
	.short 0x4d61
	.short 0x7274	/* moveq #116,d1 */
	bvss Le0
	moveal d2,a0
	bcss Le8
	bgts Ldc
	.short 0x7400	/* moveq #0,d2 */
	.short 0x0000,0x002c	/* orib #44,d0 */
	.byte 0x00,0x00,0x00
L81:
	.byte 0x8a	/* orib #-118,d0 */
	.short 0x0000,0x00ce	/* orib #-50,d0 */
	.byte 0x00,0x00,0x00
L89:
	.byte 0xf0	/* orib #-16,d0 */
	.byte 0x00
L8b:
	.byte 0x00,0x01
L8d:
	.byte 0x20	/* orib #32,d0 */
	.short 0x0000,0x0138	/* orib #56,d0 */
	.short 0x0000,0x0148	/* orib #72,d0 */
	.byte 0x00
L97:
	.byte 0x00,0x00
L99:
	.byte 0x00	/* orib #0,d0 */
	.short 0x0000,0x0188	/* orib #-120,d0 */
	.byte 0x00,0x00,0x01
La1:
	.byte 0x98	/* orib #-104,d0 */
	.byte 0x00
La3:
	.byte 0x00
La4:
	.byte 0x01
La5:
	.byte 0xa8	/* orib #-88,d0 */
La6:
	.short 0x0000,0x0200	/* orib #0,d0 */
	.short 0x0000,0x021c	/* orib #28,d0 */
	.byte 0x00
Laf:
	.byte 0x00,0x02,0x24	/* orib #36,d0 */
	.short 0x0000,0x022c	/* orib #44,d0 */
	.short 0x0000,0x0244	/* orib #68,d0 */
	.short 0x0000,0x0260	/* orib #96,d0 */
	.short 0x0000,0x0278	/* orib #120,d0 */
	.byte 0x00,0x00,0x02
Lc5:
	.byte 0x94	/* orib #-108,d0 */
	.short 0x0000,0x02d4	/* orib #-44,d0 */
	.short 0xffff
	.short 0xffff
	.short 0xa008
	btst d4,d0
	.short 0x800a
	.short 0x0000,0x001e	/* orib #30,d0 */
	.short 0xa00e
	.byte 0x06,0x00
Ldc:
	.byte 0x90,0x14	/* addib #20,d0 */
	.byte 0x00,0x28
Le0:
	.byte 0x90,0x16,0x00,0x06	/* orib #22,a0@(6) */
	orb a0@+,d0
	.byte 0x00,0x00
Le8:
	.byte 0x00,0x36	/* orib #54,d0 */
	.short 0x0000,0x0000	/* orib #0,d0 */
	.short 0x0000,0x2f0d	/* orib #13,d0 */
	moveal d0,a5
	clrw a5@(32)
	movel a6,a5@(34)
	movel a0,a5@(38)
	moveal sp@+,a5
	btst #3,a6@(297)
	beqs L11a
	.short 0x0c6e,0x0027,0x0014	/* cmpiw #39,a6@(20) */
	bcss L11c
	btst #6,a6@(297)
	bnes L11c
L11a:
	.short 0x7000	/* moveq #0,d0 */
L11c:
	rts
	.short 0x0000,0x7048	/* orib #72,d0 */
	addl d0,d0
	fmovel d0,fpcr
	.short 0x526e,0x0020	/* addqw #1,a6@(32) */
	bclr #3,a6@(42)
	movel a6,d0
L134:
	rts
	.short 0x0000,0x7000	/* orib #0,d0 */
	.short 0x536e,0x0020	/* subqw #1,a6@(32) */
	bnes L134
	btst #3,a6@(42)
	beqs L134
	moveml d1-d2/a0-a1/a5-a6,sp@-
	moveal a6,a5
	moveal a5@(34),a6
	tstw a5@(32)
	beqs L164
	bset #3,a5@(42)
	.short 0x7000	/* moveq #0,d0 */
	bras L182
	.byte 0x00,0x00
L164:
	.byte 0x24,0x2d	/* orib #45,d0 */
	.short 0x0026,0x224d	/* orib #77,a6@- */
	jsr a6@(-252)
	moveal a5,a1
	.short 0x7000	/* moveq #0,d0 */
	movew a5@(16),d0
	subal d0,a1
	addw a5@(18),d0
	jsr a6@(-210)
	movel d2,d0
L182:
	moveml sp@+,d1-d2/a0-a1/a5-a6
	rts
	moveml d0-d1,sp@-
	fmoved sp@+,%fp0
	fmovel %fp0,d0
	rts
	.short 0x0000,0xf200	/* orib #0,d0 */
	negxb d0
	fmoved %fp0,sp@-
	movel sp@+,d0
	movel sp@+,d1
	rts
	.short 0x0000,0x4a80	/* orib #-128,d0 */
	bmis L1d8
	tstl d2
	bpls L1c8
	tstl d0
	bnes L20a
	tstl d1
	bnes L20a
	tstl d3
	bnes L20a
	movel d2,d0
	addl d0,d0
	bnes L20a
	.short 0x7000	/* moveq #0,d0 */
	rts
	.byte 0x00,0x00
L1c8:
	.byte 0xb0,0x82	/* orib #-126,d0 */
	bmis L216
	bgts L20a
	cmpl d1,d3
	bcss L20a
	bnes L216
	.short 0x7000	/* moveq #0,d0 */
	rts
L1d8:
	tstl d2
	bmis L1f0
	bnes L216
	tstl d3
	bnes L216
	tstl d1
	bnes L216
	addl d0,d0
	bnes L216
	.short 0x7000	/* moveq #0,d0 */
	rts
	.byte 0x00,0x00
L1f0:
	.byte 0xb4,0x80	/* orib #-128,d0 */
	bmis L216
	bgts L20a
	cmpl d3,d1
	bcss L20a
	bhis L216
L1fc:
	.short 0x7000	/* moveq #0,d0 */
	rts
	addl d0,d0
	bcss L210
	bnes L20a
	tstl d1
	beqs L1fc
L20a:
	.short 0x7001	/* moveq #1,d0 */
	rts
	.byte 0x00,0x00
L210:
	.byte 0x66,0x04	/* orib #4,d0 */
	tstl d1
	beqs L1fc
L216:
	.short 0x70ff	/* moveq #-1,d0 */
	rts
	.short 0x0000,0x0880	/* orib #-128,d0 */
	.short 0x001f,0x4e75	/* orib #117,sp@+ */
	.short 0x0000,0x0840	/* orib #64,d0 */
	.short 0x001f,0x4e75	/* orib #117,sp@+ */
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	.short 0xf000
	fmoved sp@+,%fp0
	faddd sp@,%fp0
	fmoved %fp0,sp@
	movel sp@+,d0
	movel sp@+,d1
	rts
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	andb d0,d0
	fmoved sp@+,%fp0
	moveml d2-d3,sp@-
	fsubd sp@,%fp0
	fmoved %fp0,sp@
	movel sp@+,d0
	movel sp@+,d1
	rts
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	.short 0xf000
	fmoved sp@+,%fp0
	fmuld sp@,%fp0
	fmoved %fp0,sp@
	movel sp@+,d0
	movel sp@+,d1
	rts
	.short 0x0000,0x48e7	/* orib #-25,d0 */
	andb d0,d0
	fmoved sp@+,%fp0
	moveml d2-d3,sp@-
	fdivd sp@,%fp0
	fmoved %fp0,sp@
	movel sp@+,d0
	movel sp@+,d1
	rts
	.byte 0x00,0x00
L294:
	.byte 0x4a,0x80	/* orib #-128,d0 */
	blts L2ac
	moveml d0-d1,sp@-
	fintrzd sp@,%fp0
	fmoved %fp0,sp@
	movel sp@+,d0
	movel sp@+,d1
	rts
	.byte 0x00,0x00
L2ac:
	.byte 0x48,0xe7	/* orib #-25,d0 */
	andb d0,d0
	fmoved sp@,%fp0
	fmovel fpcr,d0
	movel d0,d1
	.short 0x103c,0x0020	/* moveb #32,d0 */
	fmovel d0,fpcr
	fintx %fp0,%fp0
	fmovel d1,fpcr
	fmoved %fp0,sp@
	movel sp@+,d0
	movel sp@+,d1
	rts
	bchg #31,d0
	bsrs L294
	tstl d0
	bnes L2e2
	tstl d1
	beqs L2e6
L2e2:
	bchg #31,d0
L2e6:
	rts
