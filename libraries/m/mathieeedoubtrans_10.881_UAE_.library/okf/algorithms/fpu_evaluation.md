---
type: Algorithm
title: FPU evaluation schemes
description: How mathieeedoubtrans.library maps the public API onto 68881 instructions.
---

# FPU evaluation schemes

All routines are thin 68881 wrappers — no polynomial/rational
approximations; the FPU microcode does the work.  Doubles move through
the user stack (`movem.l d0-d1,-(sp)` / `fmove.d (sp),fp0` /
`fmove.d fp0,(sp)` / pop into d0:d1); every 18-byte stub is padded to
20 bytes with a zero word.

- Unary ops: `movem.l d0-d1,-(sp)`, one F-line op on `(a7)` in double
  format, `fmove.d fp0,(a7)`, pop to d0:d1.  Ops used: fatan(0x0a),
  fsin(0x0e), fcos(0x1d), ftan(0x0f), fsinh(0x02), fcosh(0x19),
  ftanh(0x09), fetox(0x10), flogn(0x14), flog10(0x15), fsqrt(0x04),
  fasin(0x0c), facos(0x1c).
- Sincos: `fsincos.d (a7),fp1:fp0` — sin lands in fp0 (popped to
  d0:d1), cos in fp1 is stored through the caller's a0 pointer via
  `fmove.d fp1,(a0)`.
- Pow: `2^(exp * log2(arg))` via flog2/fmul.d/ftwotox; the fbole
  (arg<=0) path classifies ±0 by re-loading exp into fp1
  (fbogt->shared +0 tail, fbne->shared NaN, EQ->1.0), and the arg<0
  path adds fintrz.d + fcmp.d (integrality test) plus
  `fmod.s #2.0,fp1` and a `bset #31,d0` sign flip for odd exponents.
- Conversions: Tieee `fmove.d (sp)+,fp0` + `fmove.s fp0,d0`
  (double->single in d0); Fieee `fmove.s d0,fp0` + `fmove.d fp0,-(sp)`
  (single->double in d0:d1).  Both are real FPU conversions here.
- Open side effect: FPCR := 0x10 unconditionally, so every math result
  is produced under extended precision + round-toward-zero.
