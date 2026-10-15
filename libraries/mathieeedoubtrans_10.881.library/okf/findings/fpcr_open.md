---
type: Finding
title: FPCR write in Open
description: Open programs the 68881 control register to 0x10 (unconditional).
---

# FPCR write in Open (corrected)

The shipped Open does:

```
moveq   #0x10,d0            ; 7010
fmove.l d0,fpcr             ; f200 9000 -- unconditional
addq.w  #1,0x20(a6)         ; OpenCnt++
bclr    #3,0x0e(a6)         ; clear LIBF_DELEXP
move.l  a6,d0
rts
```

FPCR := `0x10` on every Open — no test, no range check.  `0x10` =
extended precision + round-toward-zero (bits 5:4 of the MODE byte).

## Correction vs the earlier note

An earlier version of this finding described a *conditional* scheme —
`fmove.l fpcr,d0; beq; cmpi.w #0x40/#0x80 -> rewrite to 0x80`.  That
describes the single-precision sibling `mathieeesingtrans.library`,
not this binary.  The double-precision siblings (mathieeedoubbas and
mathieeedoubtrans) both program FPCR unconditionally, to `0x10`.

## Consequence

Callers get their double results rounded toward zero from the FPU's
control register — the value is stable across Open calls regardless
of what FPCR the application had configured (verified by the oracle:
fpcr 0x0000/0x0080/0x0010/0xdead all become 0x10).
