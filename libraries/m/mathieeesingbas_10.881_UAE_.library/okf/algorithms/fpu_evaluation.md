---
type: Algorithm
title: FPU evaluation schemes
description: How mathieeesingbas.library maps the public API onto 68881 instructions.
---

# FPU evaluation schemes

This library only implements the 12 entry points of the singbas FD
(Fix/Flt/Cmp/Tst/Abs/Neg/Add/Sub/Mul/Div/Floor/Ceil) -- there is no Pow
or transcendentals here (those live in mathieeesingtrans.library).

- Add/Sub/Mul/Div: `fmove.s d0,fp0`; `f<op>.s d1,fp0`;
  `fmove.s fp0,d0` -- pure 68881 three-instruction wrappers.
- Floor/Ceil: `fintrz.s d0,fp0`; `fcmp.s d0,fp0`; FBcc skips or takes
  `fsub.s #1.0` / `fadd.s #1.0` so trunc(x) becomes floor/ceil.
- Fix/Flt: `fmove.s`/`fmove.l` register transfers; Fix's output rounding
  follows the FPCR mode byte (Open conditionally writes 0x80 =
  double-precision + round-to-nearest).
- Tst/Cmp/Abs/Neg: NO FPU ops at all -- integer sign/magnitude tricks
  on the IEEE bit patterns (add.l carry for sign, bclr/bchg bit 31).
  `Cmp(d0,0)` branches into the Tst body (shared tail).
