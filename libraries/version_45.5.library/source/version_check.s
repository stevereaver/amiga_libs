|||
|||	version_check.s -- hidden helper of version.library 44.x/45.x
|||	(WB3.5/3.9+).  Not an LVO: LibInit stores its address at
|||	library-base +0x32, so only code that knows the private base
|||	layout can call it.
|||
|||	Entry:  d0.b = XOR key
|||	Exit:   d0   = FindSemaphore() result (SignalSemaphore* or NULL)
|||
|||	The routine XOR-decodes a 10-byte semaphore name stored in the
|||	code hunk, calls exec FindSemaphore(a1=name), then re-XORs the
|||	name back.  SysBase is fetched from AbsExecBase (0x4), not from
|||	the saved base field.  With key 0xe9 the name decodes to
|||	"« IPrefs »" (0xab/0xbb are the Amiga charset guillemets) --
|||	see okf/findings/HiddenSemaphoreCheck.md.
|||
|||	Reconstructed in assembly for fidelity: the original is a
|||	verbatim blob, and the in-.text data must sit in the code hunk
|||	with a pc-relative reference (no relocation).
|||

	.section .text
	.globl	_CheckSemaphore
_CheckSemaphore:
	moveml	d2/a2/a6,sp@-
	moveal	0x4,a6			| AbsExecBase -> SysBase
	movel	d0,d2			| d2 = key byte
	lea	_semname(pc),a2
	moveal	a2,a0
	moveq	#9,d1
1:	eorb	d2,a0@+			| deobfuscate name
	dbf	d1,1b
	moveal	a2,a1			| a1 = semaphore name
	jsr	a6@(-594)		| FindSemaphore
	moveal	a2,a0
	moveq	#9,d1
2:	eorb	d2,a0@+			| re-obfuscate name
	dbf	d1,2b
	moveml	sp@+,d2/a2/a6
	rts

||| XOR-obfuscated semaphore name (10 bytes, NUL = trailing pad)
_semname:
	.byte	0x42,0xc9,0xa0,0xb9,0x9b,0x8c,0x8f,0x9a,0xc9,0x52
