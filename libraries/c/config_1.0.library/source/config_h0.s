/*
 * config.library 1.0 -- hunk 0: CODE, byte-exact reconstruction.
 * 'config 1.0 (12.10.96)' by Adam Dawes. INI-style config file lib:
 * h0 = 2404B SAS/C-compiled code, h1 = DATA (fmt strings, globals,
 * RomTag+AUTOINIT InitTable+functab+datatab -- all in DATA hunk).
 * a4 = h1+0x7ffe small-data base (lea h1+0x7ffe relocated).
 * Lib privdata: +0x22 seglist +0x26 execbase +0x2a dos +0x2e intuition
 * +0x32 gfx (dsize 0x36).
 */
	.text

.globl	_setstr
_setstr:
L0:
	moveml	d4-d7/a2-a4/a6,%a7@-

	moveal	%d1,%a3

	lea	_h1+0x7ffe,%a4

	linkw	%a5,#-280

	movel	%d0,%a5@(-4)

	moveq	#0,%d6

	moveq	#0,%d5

	moveq	#0,%d0

	movel	%d0,%a5@(-278)

	moveq	#0,%d4

	pea	%a5@(-18)

	bsrw	_listinit

	addql	#4,%a7

	.short	0x4878,0x03ed

	movel	%a5@(-4),%a7@-

	bsrw	_dos_Open

	addql	#8,%a7

	movel	%d0,%d7

	tstl	%d7

	beqw	Lf4

	braw	Lda

L44:
	pea	%a5@(-274)

	bsrw	_strlen

	addql	#4,%a7

	subql	#1,%d0

	lea	%a5@(-274),%a0

	addal	%d0,%a0

	moveb	#0,%a0@

	pea	%a5@(-274)

	bsrw	_strlen

	addql	#4,%a7

	tstl	%d0

	bleb	Lda

	.short	0x4878,0x0001

	pea	%a5@(-274)

	bsrw	_strlen

	addql	#4,%a7

	addql	#1,%d0

	movel	%d0,%a7@-

	bsrw	_ex_AllocVec

	addql	#8,%a7

	moveal	%d0,%a2

	movel	%a2,%d0

	bneb	L9e

	movel	%d7,%a7@-

	bsrw	_dos_Close

	addql	#4,%a7

	pea	%a5@(-18)

	bsrw	_listfree

	addql	#4,%a7

	moveq	#0,%d0

	braw	L298

L9e:
	pea	%a5@(-274)

	movel	%a2,%a7@-

	bsrw	_strcpy

	addql	#8,%a7

	movel	%a2,%a7@-

	pea	%a5@(-18)

	bsrw	_listadd

	addql	#8,%a7

	tstl	%d0

	bneb	Lda

	movel	%d7,%a7@-

	bsrw	_dos_Close

	addql	#4,%a7

	movel	%a2,%a7@-

	bsrw	_ex_FreeVec

	addql	#4,%a7

	pea	%a5@(-18)

	bsrw	_listfree

	addql	#4,%a7

	moveq	#0,%d0

	braw	L298

Lda:
	.short	0x4878,0x00ff

	pea	%a5@(-274)

	movel	%d7,%a7@-

	bsrw	_dos_FGets

	lea	%a7@(12),%a7

	moveal	%d0,%a0

	movel	%a0,%d0

	bnew	L44

Lf4:
	movel	%d7,%a7@-

	bsrw	_dos_Close

	addql	#4,%a7

	.short	0x4878,0x03ee

	movel	%a5@(-4),%a7@-

	bsrw	_dos_Open

	addql	#8,%a7

	movel	%d0,%d7

	tstl	%d7

	bneb	L120

	pea	%a5@(-18)

	bsrw	_listfree

	addql	#4,%a7

	moveq	#0,%d0

	braw	L298

L120:
	moveal	%a5@(-18),%a6

	braw	L226

L128:
	moveal	%a6@(10),%a0

	cmpib	#91,%a0@

	bnew	L1b6

	movel	%a6@(10),%a7@-

	bsrw	_strlen

	addql	#4,%a7

	subql	#1,%d0

	moveal	%a6@(10),%a0

	addal	%d0,%a0

	cmpib	#93,%a0@

	bneb	L1b6

	moveq	#1,%d0

	cmpl	%d5,%d0

	bneb	L168

	tstl	%d4

	bneb	L168

	movel	%d3,%a7@-

	movel	%d2,%a7@-

	pea	%a4@(-32699)

	movel	%d7,%a7@-

	bsrw	_dos_VFPrintf

	lea	%a7@(16),%a7

L168:
	movel	%a6@(10),%a7@-

	tstl	%d6

	bneb	L176

	lea	%a4@(-32706),%a0

	brab	L17a

L176:
	lea	%a4@(-32708),%a0

L17a:
	movel	%a0,%a7@-

	pea	%a4@(-32705)

	movel	%d7,%a7@-

	bsrw	_dos_VFPrintf

	lea	%a7@(16),%a7

	movel	%a3,%a7@-

	bsrw	_strlen

	movel	%d0,%a7@

	movel	%a3,%a7@-

	moveal	%a6@(10),%a0

	pea	%a0@(1)

	bsrw	_strnicmp

	lea	%a7@(12),%a7

	tstl	%d0

	bneb	L1b2

	moveq	#1,%d5

	moveq	#1,%d0

	movel	%d0,%a5@(-278)

	brab	L222

L1b2:
	moveq	#0,%d5

	brab	L222

L1b6:
	moveq	#1,%d0

	cmpl	%d5,%d0

	bneb	L210

	movel	%d2,%a7@-

	bsrw	_strlen

	movel	%d0,%a7@

	movel	%d2,%a7@-

	movel	%a6@(10),%a7@-

	bsrw	_strnicmp

	lea	%a7@(12),%a7

	tstl	%d0

	bneb	L210

	.short	0x4878,0x0003

	pea	%a4@(-32712)

	movel	%d2,%a7@-

	bsrw	_strlen

	addql	#4,%a7

	moveal	%a6@(10),%a0

	addal	%d0,%a0

	pea	%a0@

	bsrw	_strnicmp

	lea	%a7@(12),%a7

	tstl	%d0

	bneb	L210

	movel	%d3,%a7@-

	movel	%d2,%a7@-

	pea	%a4@(-32721)

	movel	%d7,%a7@-

	bsrw	_dos_VFPrintf

	lea	%a7@(16),%a7

	moveq	#1,%d4

	brab	L222

L210:
	movel	%a6@(10),%a7@-

	pea	%a4@(-32725)

	movel	%d7,%a7@-

	bsrw	_dos_VFPrintf

	lea	%a7@(12),%a7

L222:
	moveal	%a6@,%a6

	addql	#1,%d6

L226:
	lea	%a5@(-14),%a0

	cmpal	%a6,%a0

	bnew	L128

	moveq	#1,%d0

	cmpl	%d5,%d0

	bneb	L24c

	tstl	%d4

	bneb	L24c

	movel	%d3,%a7@-

	movel	%d2,%a7@-

	pea	%a4@(-32734)

	movel	%d7,%a7@-

	bsrw	_dos_VFPrintf

	lea	%a7@(16),%a7

L24c:
	tstl	%a5@(-278)

	bneb	L284

	movel	%a3,%a7@-

	tstl	%d6

	bneb	L25e

	lea	%a4@(-32743),%a0

	brab	L262

L25e:
	lea	%a4@(-32745),%a0

L262:
	movel	%a0,%a7@-

	pea	%a4@(-32742)

	movel	%d7,%a7@-

	bsrw	_dos_VFPrintf

	lea	%a7@(16),%a7

	movel	%d3,%a7@-

	movel	%d2,%a7@-

	pea	%a4@(-32754)

	movel	%d7,%a7@-

	bsrw	_dos_VFPrintf

	lea	%a7@(16),%a7

L284:
	movel	%d7,%a7@-

	bsrw	_dos_Close

	addql	#4,%a7

	pea	%a5@(-18)

	bsrw	_listfree

	addql	#4,%a7

	moveq	#1,%d0

L298:
	unlk	%a5

	moveml	%a7@+,d4-d7/a2-a4/a6

	rts	

.globl	_setnum
_setnum:
L2a0:
	moveml	d4/a2-a4,%a7@-

	moveal	%d0,%a3

	moveal	%d1,%a2

	lea	_h1+0x7ffe,%a4

	linkw	%a5,#-20

	movel	%d3,%a7@-

	pea	%a4@(-32758)

	pea	%a5@(-20)

	bsrw	_sprintf

	lea	%a7@(12),%a7

	movel	%a2,%d1

	lea	%a5@(-20),%a0

	movel	%a0,%d4

	movel	%a3,%d0

	exg	%d4,%d3

	bsrw	_setstr

	exg	%d4,%d3

	unlk	%a5

	moveml	%a7@+,d4/a2-a4

	rts	

.globl	_getstr
_getstr:
L2de:
	moveml	d6-d7/a2-a4,%a7@-

	moveal	%d0,%a3

	moveal	%d1,%a2

	lea	_h1+0x7ffe,%a4

	linkw	%a5,#-256

	moveq	#0,%d6

	.short	0x4878,0x03ed

	movel	%a3,%a7@-

	bsrw	_dos_Open

	addql	#8,%a7

	movel	%d0,%d7

	tstl	%d7

	bnew	L434

	movel	%d5,%a7@-

	bsrw	_strlen

	addql	#4,%a7

	cmpl	%d0,%d4

	bgtb	L31c

	moveq	#0,%d0

	braw	L474

	braw	L434

L31c:
	movel	%d5,%a7@-

	movel	%d3,%a7@-

	bsrw	_strcpy

	addql	#8,%a7

	moveq	#1,%d0

	braw	L474

	braw	L434

L330:
	pea	%a5@(-256)

	bsrw	_strlen

	addql	#4,%a7

	subql	#1,%d0

	lea	%a5@(-256),%a0

	addal	%d0,%a0

	moveb	#0,%a0@

	pea	%a5@(-256)

	bsrw	_strlen

	addql	#4,%a7

	tstl	%d0

	blew	L434

	cmpib	#91,%a5@(-256)

	bneb	L39c

	pea	%a5@(-256)

	bsrw	_strlen

	addql	#4,%a7

	subql	#1,%d0

	lea	%a5@(-256),%a0

	addal	%d0,%a0

	cmpib	#93,%a0@

	bneb	L39c

	movel	%a2,%a7@-

	bsrw	_strlen

	movel	%d0,%a7@

	movel	%a2,%a7@-

	pea	%a5@(-255)

	bsrw	_strnicmp

	lea	%a7@(12),%a7

	tstl	%d0

	bneb	L396

	moveq	#1,%d6

	braw	L434

L396:
	moveq	#0,%d6

	braw	L434

L39c:
	moveq	#1,%d0

	cmpl	%d6,%d0

	bnew	L434

	movel	%d2,%a7@-

	bsrw	_strlen

	movel	%d0,%a7@

	movel	%d2,%a7@-

	pea	%a5@(-256)

	bsrw	_strnicmp

	lea	%a7@(12),%a7

	tstl	%d0

	bnew	L434

	.short	0x4878,0x0003

	pea	%a4@(-32762)

	movel	%d2,%a7@-

	bsrw	_strlen

	addql	#4,%a7

	lea	%a5@(-256),%a0

	addal	%d0,%a0

	pea	%a0@

	bsrw	_strnicmp

	lea	%a7@(12),%a7

	tstl	%d0

	bneb	L434

	movel	%d2,%a7@-

	bsrw	_strlen

	addql	#4,%a7

	addql	#3,%d0

	lea	%a5@(-256),%a0

	addal	%d0,%a0

	pea	%a0@

	bsrw	_strlen

	addql	#4,%a7

	cmpl	%d0,%d4

	bgtb	L40e

	movel	%d7,%a7@-

	bsrw	_dos_Close

	addql	#4,%a7

	moveq	#0,%d0

	brab	L474

	brab	L434

L40e:
	movel	%d7,%a7@-

	bsrw	_dos_Close

	addql	#4,%a7

	movel	%d2,%a7@-

	bsrw	_strlen

	addql	#4,%a7

	addql	#3,%d0

	lea	%a5@(-256),%a0

	addal	%d0,%a0

	pea	%a0@

	movel	%d3,%a7@-

	bsrw	_strcpy

	addql	#8,%a7

	moveq	#1,%d0

	brab	L474

L434:
	.short	0x4878,0x0100

	pea	%a5@(-256)

	movel	%d7,%a7@-

	bsrw	_dos_FGets

	lea	%a7@(12),%a7

	moveal	%d0,%a0

	movel	%a0,%d0

	bnew	L330

	movel	%d7,%a7@-

	bsrw	_dos_Close

	addql	#4,%a7

	movel	%d5,%a7@-

	bsrw	_strlen

	addql	#4,%a7

	cmpl	%d0,%d4

	bgtb	L468

	moveq	#0,%d0

	brab	L474

	brab	L474

L468:
	movel	%d5,%a7@-

	movel	%d3,%a7@-

	bsrw	_strcpy

	addql	#8,%a7

	moveq	#1,%d0

L474:
	unlk	%a5

	moveml	%a7@+,d6-d7/a2-a4

	rts	

.globl	_getnum
_getnum:
L47c:
	moveml	d4-d6/a2-a4,%a7@-

	moveal	%d0,%a3

	moveal	%d1,%a2

	lea	_h1+0x7ffe,%a4

	linkw	%a5,#-44

	movel	%d3,%a7@-

	pea	%a4@(-32766)

	pea	%a5@(-20)

	bsrw	_sprintf

	lea	%a7@(12),%a7

	movel	%a3,%d0

	movel	%a2,%d1

	moveq	#20,%d4

	lea	%a5@(-20),%a0

	movel	%a0,%d5

	lea	%a5@(-40),%a0

	movel	%a0,%d6

	exg	%d6,%d3

	bsrw	_getstr

	exg	%d6,%d3

	pea	%a5@(-44)

	pea	%a5@(-40)

	bsrw	_dos_StrToLong

	addql	#8,%a7

	movel	%a5@(-44),%d0

	unlk	%a5

	moveml	%a7@+,d4-d6/a2-a4

	rts	

.globl	_listinit
_listinit:
L4d4:
	moveal	%a7@(4),%a0

	lea	%a0@(4),%a1

	movel	%a1,%a0@

	moveq	#0,%d0

	movel	%d0,%a0@(4)

	movel	%a0,%a0@(8)

	moveb	#1,%a0@(12)

	rts	

.globl	_listadd
_listadd:
L4f0:
	moveml	a2-a3/a6,%a7@-

	moveal	%a7@(16),%a3

	moveal	%a7@(20),%a2

	.short	0x4878,0x0001

	.short	0x4878,0x000e

	bsrw	_ex_AllocVec

	addql	#8,%a7

	moveal	%d0,%a6

	movel	%a6,%d0

	bneb	L514

	moveq	#0,%d0

	brab	L530

L514:
	movel	%a2,%a6@(10)

	moveb	#0,%a6@(9)

	moveb	#1,%a6@(8)

	movel	%a6,%a7@-

	movel	%a3,%a7@-

	bsrw	_ex_AddTail

	addql	#8,%a7

	moveq	#1,%d0

L530:
	moveml	%a7@+,a2-a3/a6

	rts	

.globl	_listfree
_listfree:
L536:
	moveml	a2-a3,%a7@-

	moveal	%a7@(12),%a3

	brab	L55c

L540:
	moveal	%a3@,%a2

	movel	%a2@(10),%a7@-

	bsrw	_ex_FreeVec

	addql	#4,%a7

	movel	%a3,%a7@-

	bsrw	_ex_RemHead

	addql	#4,%a7

	movel	%a2,%a7@-

	bsrw	_ex_FreeVec

	addql	#4,%a7

L55c:
	lea	%a3@(4),%a0

	cmpal	%a3@,%a0

	bneb	L540

	moveml	%a7@+,a2-a3

	rts	

.globl	_strlen
_strlen:
L56a:
	moveal	%a7@(4),%a0

	moveq	#0,%d0

	brab	L574

L572:
	addql	#1,%d0

L574:
	moveal	%a0,%a1

	addql	#1,%a0

	tstb	%a1@

	bneb	L572

	rts	

.globl	_strcpy
_strcpy:
L57e:
	moveml	a2-a3,%a7@-

	moveal	%a7@(12),%a0

	moveal	%a7@(16),%a1

	brab	L596

L58c:
	moveal	%a0,%a2

	addql	#1,%a0

	moveal	%a1,%a3

	addql	#1,%a1

	moveb	%a3@,%a2@

L596:
	tstb	%a1@

	bneb	L58c

	moveb	#0,%a0@

	moveml	%a7@+,a2-a3

	rts	

.globl	_strnicmp
_strnicmp:
L5a4:
	moveml	d2-d4/d7,%a7@-

	moveal	%a7@(20),%a0

	moveal	%a7@(24),%a1

	movel	%a7@(28),%d0

	moveq	#1,%d1

	moveq	#0,%d7

	brab	L602

L5ba:
	cmpib	#97,%a0@

	bltb	L5d2

	cmpib	#122,%a0@

	bgtb	L5d2

	moveb	%a0@,%d2

	extw	%d2

	extl	%d2

	moveq	#32,%d3

	subl	%d3,%d2

	brab	L5d8

L5d2:
	moveb	%a0@,%d2

	extw	%d2

	extl	%d2

L5d8:
	cmpib	#97,%a1@

	bltb	L5f0

	cmpib	#122,%a1@

	bgtb	L5f0

	moveb	%a1@,%d3

	extw	%d3

	extl	%d3

	moveq	#32,%d4

	subl	%d4,%d3

	brab	L5f6

L5f0:
	moveb	%a1@,%d3

	extw	%d3

	extl	%d3

L5f6:
	cmpl	%d2,%d3

	beqb	L5fc

	moveq	#0,%d1

L5fc:
	addql	#1,%a0

	addql	#1,%a1

	addql	#1,%d7

L602:
	cmpl	%d7,%d0

	bleb	L60c

	moveq	#1,%d3

	cmpl	%d1,%d3

	beqb	L5ba

L60c:
	moveq	#1,%d3

	cmpl	%d1,%d3

	bneb	L616

	moveq	#0,%d3

	brab	L618

L616:
	moveq	#1,%d3

L618:
	moveb	%d3,%d1

	extw	%d1

	extl	%d1

	movel	%d1,%d0

	moveml	%a7@+,d2-d4/d7

	rts	

	nop	

.globl	_opendeps
_opendeps:
L628:
	movel	%a4,%a7@-

	lea	_h1+0x7ffe,%a4

	movel	4:w,%a4@(-32690)

	.short	0x4878,0x0025

	pea	%a4@(-32501)

	bsrw	_ex_OpenLibrary

	addql	#8,%a7

	movel	%d0,%a4@(-32686)

	tstl	%a4@(-32686)

	bneb	L652

	moveq	#0,%d0

	brab	L6aa

L652:
	.short	0x4878,0x0025

	pea	%a4@(-32519)

	bsrw	_ex_OpenLibrary

	addql	#8,%a7

	movel	%d0,%a4@(-32682)

	tstl	%a4@(-32682)

	bneb	L66e

	moveq	#0,%d0

	brab	L6aa

L66e:
	.short	0x4878,0x0025

	pea	%a4@(-32536)

	bsrw	_ex_OpenLibrary

	addql	#8,%a7

	movel	%d0,%a4@(-32678)

	tstl	%a4@(-32678)

	bneb	L68a

	moveq	#0,%d0

	brab	L6aa

L68a:
	moveal	%a4@(-32434),%a0

	movel	%a4@(-32686),%a0@(42)

	moveal	%a4@(-32434),%a0

	movel	%a4@(-32682),%a0@(46)

	moveal	%a4@(-32434),%a0

	movel	%a4@(-32678),%a0@(50)

	moveq	#1,%d0

L6aa:
	moveal	%a7@+,%a4

	rts	

.globl	_closedeps
_closedeps:
L6ae:
	movel	%a4,%a7@-

	lea	_h1+0x7ffe,%a4

	tstl	%a4@(-32678)

	beqb	L6c6

	movel	%a4@(-32678),%a7@-

	bsrw	_ex_CloseLibrary

	addql	#4,%a7

L6c6:
	tstl	%a4@(-32682)

	beqb	L6d6

	movel	%a4@(-32682),%a7@-

	bsrw	_ex_CloseLibrary

	addql	#4,%a7

L6d6:
	tstl	%a4@(-32686)

	beqb	L6e6

	movel	%a4@(-32686),%a7@-

	bsrw	_ex_CloseLibrary

	addql	#4,%a7

L6e6:
	moveal	%a7@+,%a4

	rts	

	nop	

.globl	_null0
_null0:
L6ec:
	movel	%a4,%a7@-

	lea	_h1+0x7ffe,%a4

	moveq	#0,%d0

	moveal	%a7@+,%a4

	rts	

	.short	0

.globl	_initfn
_initfn:
L6fc:
	moveml	a2-a4,%a7@-

	moveal	%a0,%a3

	moveal	%d0,%a2

	lea	_h1+0x7ffe,%a4

	movel	%a2,%a4@(-32434)

	moveal	%a4@(-32434),%a0

	movel	%a6,%a0@(38)

	moveal	%a4@(-32434),%a0

	movel	%a3,%a0@(34)

	bsrw	_opendeps

	tstl	%d0

	beqb	L72c

	movel	%a4@(-32434),%d0

	brab	L732

L72c:
	bsrw	_closedeps

	moveq	#0,%d0

L732:
	moveml	%a7@+,a2-a4

	rts	

.globl	_open
_open:
L738:
	movel	%a4,%a7@-

	lea	_h1+0x7ffe,%a4

	addqw	#1,%a6@(32)

	andib	#247,%a6@(14)

	movel	%a6,%d0

	moveal	%a7@+,%a4

	rts	

.globl	_close
_close:
L750:
	movel	%a4,%a7@-

	lea	_h1+0x7ffe,%a4

	subqw	#1,%a6@(32)

	tstw	%a6@(32)

	bneb	L772

	btstb	#3,%a6@(14)

	beqb	L772

	bsrb	_expunge

	moveal	%d0,%a0

	movel	%a0,%d0

	brab	L774

L772:
	moveq	#0,%d0

L774:
	moveal	%a7@+,%a4

	rts	

.globl	_expunge
_expunge:
L778:
	moveml	d5-d7/a2-a4/a6,%a7@-

	lea	_h1+0x7ffe,%a4

	linkw	%a5,#-4

	movel	%a6,%a5@(-4)

	moveal	%a5@(-4),%a3

	tstw	%a3@(32)

	bneb	L7ca

	moveal	%a3,%a6

	moveal	%a3@(34),%a2

	movel	%a3,%a7@-

	bsrw	_ex_Remove

	addql	#4,%a7

	bsrw	_closedeps

	moveq	#0,%d7

	movew	%a3@(16),%d7

	moveq	#0,%d6

	movew	%a3@(18),%d6

	movel	%d7,%d5

	addl	%d6,%d5

	movel	%d7,%d0

	negl	%d0

	addal	%d0,%a6

	movel	%d5,%a7@-

	movel	%a6,%a7@-

	bsrw	_ex_FreeMem

	addql	#8,%a7

	movel	%a2,%d0

	brab	L7d2

L7ca:
	bsetb	#3,%a3@(14)

	moveq	#0,%d0

L7d2:
	unlk	%a5

	moveml	%a7@+,d5-d7/a2-a4/a6

	rts	

.globl	_nullv
_nullv:
L7da:
	movel	%a4,%a7@-

	lea	_h1+0x7ffe,%a4

	moveq	#0,%d0

	moveal	%a7@+,%a4

	rts	

.globl	_dos_Close
_dos_Close:
L7e8:
	movel	%a6,%a7@-

	moveal	%a4@(-32686),%a6

	nop	

	movel	%a7@(8),%d1

	jsr	%a6@(-36)

	moveal	%a7@+,%a6

	rts	

.globl	_dos_FGets
_dos_FGets:
L7fc:
	moveml	d2-d3/a6,%a7@-

	moveal	%a4@(-32686),%a6

	nop	

	moveml	%a7@(16),d1-d3

	jsr	%a6@(-336)

	moveml	%a7@+,d2-d3/a6

	rts	

	.short	0

.globl	_dos_VFPrintf
_dos_VFPrintf:
L818:
	moveml	d2-d3/a6,%a7@-

	moveal	%a4@(-32686),%a6

	nop	

	pea	%a7@(24)

	movel	%a7@+,%d3

	moveml	%a7@(16),d1-d2

	jsr	%a6@(-354)

	moveml	%a7@+,d2-d3/a6

	rts	

.globl	_dos_Open
_dos_Open:
L838:
	moveml	d2/a6,%a7@-

	moveal	%a4@(-32686),%a6

	nop	

	moveml	%a7@(12),d1-d2

	jsr	%a6@(-30)

	moveml	%a7@+,d2/a6

	rts	

	.short	0

.globl	_dos_StrToLong
_dos_StrToLong:
L854:
	moveml	d2/a6,%a7@-

	moveal	%a4@(-32686),%a6

	nop	

	moveml	%a7@(12),d1-d2

	jsr	%a6@(-816)

	moveml	%a7@+,d2/a6

	rts	

	.short	0

.globl	_ex_AddTail
_ex_AddTail:
L870:
	movel	%a6,%a7@-

	moveal	%a4@(-32690),%a6

	nop	

	moveml	%a7@(8),a0-a1

	jsr	%a6@(-246)

	moveal	%a7@+,%a6

	rts	

	.short	0

.globl	_ex_AllocVec
_ex_AllocVec:
L888:
	movel	%a6,%a7@-

	moveal	%a4@(-32690),%a6

	nop	

	moveml	%a7@(8),d0-d1

	jsr	%a6@(-684)

	moveal	%a7@+,%a6

	rts	

	.short	0

.globl	_ex_CloseLibrary
_ex_CloseLibrary:
L8a0:
	movel	%a6,%a7@-

	moveal	%a4@(-32690),%a6

	nop	

	moveal	%a7@(8),%a1

	jsr	%a6@(-414)

	moveal	%a7@+,%a6

	rts	

.globl	_ex_FreeMem
_ex_FreeMem:
L8b4:
	movel	%a6,%a7@-

	moveal	%a4@(-32690),%a6

	nop	

	moveal	%a7@(8),%a1

	movel	%a7@(12),%d0

	jsr	%a6@(-210)

	moveal	%a7@+,%a6

	rts	

.globl	_ex_FreeVec
_ex_FreeVec:
L8cc:
	movel	%a6,%a7@-

	moveal	%a4@(-32690),%a6

	nop	

	moveal	%a7@(8),%a1

	jsr	%a6@(-690)

	moveal	%a7@+,%a6

	rts	

.globl	_ex_OpenLibrary
_ex_OpenLibrary:
L8e0:
	movel	%a6,%a7@-

	moveal	%a4@(-32690),%a6

	nop	

	moveal	%a7@(8),%a1

	movel	%a7@(12),%d0

	jsr	%a6@(-552)

	moveal	%a7@+,%a6

	rts	

.globl	_ex_RemHead
_ex_RemHead:
L8f8:
	movel	%a6,%a7@-

	moveal	%a4@(-32690),%a6

	nop	

	moveal	%a7@(8),%a0

	jsr	%a6@(-258)

	moveal	%a7@+,%a6

	rts	

.globl	_ex_Remove
_ex_Remove:
L90c:
	movel	%a6,%a7@-

	moveal	%a4@(-32690),%a6

	nop	

	moveal	%a7@(8),%a1

	jsr	%a6@(-252)

	moveal	%a7@+,%a6

	rts	

.globl	_sprintf
_sprintf:
L920:
	moveml	a2-a4/a6,%a7@-

	moveal	%a7@(20),%a3

	moveal	%a7@(24),%a0

	lea	%a7@(28),%a1

	lea	_putch(%pc),%a2

	.short	0x2c79
	.long	4

	jsr	%a6@(-522)

	moveml	%a7@+,a2-a4/a6

	rts	

.globl	_putch
_putch:
L944:
	moveb	%d0,%a3@+

	rts	

.globl	_r0a
_r0a:
L948:
	moveq	#0,%d0

	rts	

.globl	_r1a
_r1a:
L94c:
	moveq	#1,%d0

	rts	

.globl	_r0b
_r0b:
L950:
	moveq	#0,%d0

	rts	

.globl	_r1b
_r1b:
L954:
	moveq	#1,%d0

	rts	

.globl	_rtsc
_rtsc:
L958:
	rts	

	nop	

.globl	_rtsd
_rtsd:
L95c:
	rts	

	nop	

.globl	_rtse
_rtse:
L960:
	rts	

	nop	
