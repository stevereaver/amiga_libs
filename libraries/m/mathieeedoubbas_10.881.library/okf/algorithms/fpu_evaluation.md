---
type: Algorithm
title: FPU evaluation schemes
description: How mathieeedoubbas.library maps the public API onto 68881 instructions.
---

# FPU evaluation schemes

All routines are thin 68881 wrappers -- no polynomial/rational
approximations; the FPU microcode does the work.  This library exports
only the 12 basic primitives (LVOs -30..-96); the transcendentals live
in mathieeedoubtrans.library.

- **ABI**: doubles passed in d0:d1 (hi:lo) and, for dyads, d2:d3;
  result in d0:d1.  Doubles are ferried to/from the FPU through the
  user stack: `movem.l d0-d3,-(sp)` then `fmove.d (sp)+,fp0` /
  `fadd.d (sp),fp0` for the second operand, result stored back with
  `fmove.d fp0,(sp)` and popped into d0:d1.
- **Fix**: push double, `fmove.d (sp)+,fp0`, `fmove.l fp0,d0` --
  integer conversion uses the FPCR rounding mode (Open sets 0x10 =
  extended precision + round-to-zero, i.e. C-style truncation).
- **Flt**: `fmove.l d0,fp0`, `fmove.d fp0,-(sp)`, pop d0:d1.
- **Add/Sub/Mul/Div**: `fmove.d (sp)+,fp0; f<op>.d (sp),fp0;
  fmove.d fp0,(sp)`; the result overwrites the second operand's slot.
- **Floor/Ceil**: `fmove.d (sp),fp1` (keep x), `fintrz fp1,fp0`,
  `fcmp fp1,fp0` (fp0 - fp1), `fbule`/`fbuge` keep-truncated, else
  adjust by `-1.0`/`+1.0` via a *single*-precision immediate
  (`fsub.s`/`fadd.s #0e1`).
- **Cmp/Tst**: pure integer sign-magnitude compares on the IEEE bit
  patterns -- no FPU ops at all.  `add.l d0,d0` puts the sign in C and
  the high-word-zero-ness in Z; negative operands compare reversed.
- **Abs/Neg**: `bclr`/`bchg #31,d0` on the sign bit of the high word.
