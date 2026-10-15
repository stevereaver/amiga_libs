|||
|||	fantasia_hw.s -- joystick decoders of fantasia.library 1.0.
|||
|||	Assembled verbatim from the original code (IRA disasm
|||	work/fantasia_1.0.asm).  Both functions are unusual:
|||	they return their result in d3 / d2 -- not d0 -- and the
|||	button decoder uses absolute `jmp` instructions for its
|||	tail merges (which is why the original binary carries
|||	relocations into this code at 0x22c, 0x246, ...).
|||
|||	JOY1DAT $dff00c : joystick/mouse counter port 1
|||	                  bits 0,1 = X quadrature, bits 8,9 = Y
|||	POTGOR  $dff016 : pot data bits (14 = DATRY, 12 = DATLX)
|||	CIAA_PRA $bfe001: CIA-A port A (bit 7 = joy1 fire, low-active)
|||

	.section .text

JOY1DAT		= 0xdff00c
POTGOR		= 0xdff016
CIAA_PRA	= 0xbfe001

|||
|||	JoyDir -- LVO -30, original code+0x138.
|||	Decodes JOY1DAT into a direction/state index in d3
|||	(0..8).  The bit-9 state selects between two quadrant
|||	maps; the (d4 ^ d4>>1) gray-code edge and bits 8/1 pick
|||	the direction.
|||
	.globl	_JoyDir
_JoyDir:
	clr.l	d0
	clr.l	d3
	clr.l	d4
	clr.l	d5
	move.w	JOY1DAT,d0
	btst	#9,d0
	bne.w	.L1B
	move.w	JOY1DAT,d4
	move.w	d4,d5
	lsr.w	#1,d5
	eor.w	d4,d5
	btst	#0,d5
	bne.w	.L16
	btst	#8,d4
	bne.w	.L18
	move.w	JOY1DAT,d0
	btst	#1,d0
	bne.w	.L1A
	bra.w	.L1E
.L16:
	move.w	JOY1DAT,d0
	btst	#1,d0
	bne.w	.L17
	move.l	#5,d3
	bra.w	.L1F
.L17:
	move.l	#4,d3
	bra.w	.L1F
.L18:
	move.w	JOY1DAT,d0
	btst	#1,d0
	bne.w	.L19
	move.l	#1,d3
	bra.w	.L1F
.L19:
	move.l	#2,d3
	bra.w	.L1F
.L1A:
	move.l	#3,d3
	bra.w	.L1F
.L1B:
	move.w	JOY1DAT,d4
	move.w	d4,d5
	lsr.w	#1,d5
	eor.w	d4,d5
	btst	#0,d5
	bne.w	.L1D
	btst	#8,d4
	bne.w	.L1C
	move.l	#8,d3
	bra.w	.L1F
.L1C:
	move.l	#7,d3
	bra.w	.L1F
.L1D:
	move.l	#6,d3
	bra.w	.L1F
.L1E:
	move.l	#0,d3
.L1F:
	rts

|||
|||	JoyButtons -- LVO -36, original code+0x20c.
|||	Reads CIA-A PRA bit7 (fire, active low) and POTGOR
|||	bits 14/12; returns a button-combination index in d2
|||	({0,1,2,4}).  Contains absolute `jmp` tail-merges and
|||	unreachable dead `jmp`s, reproduced verbatim.
|||
	.globl	_JoyButtons
_JoyButtons:
	clr.l	d0
	clr.l	d2
	btst	#7,CIAA_PRA
	beq.w	.L21
	move.w	POTGOR,d0
	btst	#14,d0
	beq.w	.L23
	jmp	.L25
.L21:
	move.w	POTGOR,d0
	btst	#14,d0
	beq.w	.L22
	move.l	#1,d2
	jmp	.L26
.L22:
	move.l	#4,d2
	jmp	.L26
	jmp	.L26				| unreachable in original
	jmp	.L26				| unreachable in original
.L23:
	move.w	POTGOR,d0
	btst	#12,d0
	beq.w	.L24
	move.l	#2,d2
	jmp	.L26
.L24:
	jmp	.L26
	jmp	.L26				| unreachable in original
.L25:
	move.l	#0,d2
.L26:
	rts
