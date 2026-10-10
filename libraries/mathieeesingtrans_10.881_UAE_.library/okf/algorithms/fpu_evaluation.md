---
type: Algorithm
title: FPU evaluation schemes
description: How mathieeesingtrans.library maps the public API onto 68881 instructions.
---

# FPU evaluation schemes

All routines are thin 68881 wrappers -- no polynomial/rational
approximations; the FPU microcode does the work.

- Unary ops: load operand (fmove.s / fmove.d), single F-line op,
  store result. Ops used: fatan, fsin, fcos, ftan, fsincos, fsinh,
  fcosh, ftanh, fetox, flogn, flog10, fsqrt, fasin, facos, fadd,
  fsub, fmul, fdiv (subset per library).
- Pow: `2^(exp * log2(arg))` via flog2/fmul/ftwotox; negative-arg path
  adds fintrz + fcmp (integrality test) and fmod-2 for the sign.
- Floor/Ceil: `fintrz(x)` then fcmp against x; adjust by -1/+1
  (constant `fsub.s #1` / `fadd.s #1`) when trunc is on the wrong side.
- Compare/Test: pure integer sign-magnitude compares on the IEEE bit
  patterns -- no FPU ops at all.
- Fix/Flt: fmove.l/fmove.s/fmove.d register transfers (rounding per
  FPCR as programmed by Open: 0x80 (conditional)).
