---
type: Algorithm
title: FPU evaluation schemes
description: How mathieeesingtrans.library maps the public API onto 68881 instructions.
---

# FPU evaluation schemes

All routines are thin 68881 wrappers -- no polynomial/rational
approximations; the FPU microcode does the work.  Argument in d0
(IEEE single bit pattern, fp0 via `fX.s d0,fp0`), result stored back to
d0 via `fmove.s fp0,d0`; each 10-byte stub is padded to 12.

- Unary transcendentals (one F-line op each, extension word 0x44xx):
  fsin=440e, fcos=441d, ftan=440f, fsinh=4402, fcosh=4419, ftanh=4409,
  fasin=440c, facos=441c, fatan=440a, fsqrt=4404, fetox=4410,
  flogn=4414, flog10=4415.
- Sincos: `fsincos.s d0,fp1:fp0` leaves cos in fp1 (stored to *a0) and
  sin in fp0 (returned in d0).
- Tieee/Fieee: identity -- shared bare RTS at 0x1a4.
- Pow: `2^(exp * log2(arg))` via flog2/fmul/ftwotox; the negative-arg
  path negates the base, tests exp integrality with fintrz + fcmp,
  then applies the sign via `fmod(trunc(exp),2)` + `bset #31`.
- Open also touches the FPU: `fmove.l fpcr,d0` / `fmove.l #0x80,fpcr`
  (conditional rounding-mode upgrade).
