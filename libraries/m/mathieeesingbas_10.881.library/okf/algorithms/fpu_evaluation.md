---
type: Algorithm
title: FPU evaluation schemes
description: How mathieeesingbas.library maps the public API onto 68881 instructions.
---

# FPU evaluation schemes

mathieeesingbas (the "bas" = basics) exports only the 12 arithmetic /
conversion primitives — no transcendentals, no Pow (those live in
mathieeesingtrans.library).  Every routine is a thin 68881 wrapper;
the FPU microcode does the work.  fp0 is the only FP register used.

- Add/Sub/Mul/Div: `fmove.s d0,fp0; f<op>.s d1,fp0; fmove.s fp0,d0; rts`
  — ops used: fadd.s 0x22, fsub.s 0x28, fmul.s 0x23, fdiv.s 0x20.
  Each is followed by a `0000` pad word so bodies sit on 0x10 stride.
- Fix: `fmove.s d0,fp0; fmove.l fp0,d0` (integer rounding per FPCR
  mode; Open leaves it at double-precision + round-nearest).
- Flt: `fmove.l d0,fp0; fmove.s fp0,d0`.
- Floor/Ceil: `fintrz.s d0,fp0; fcmp.s d0,fp0` then `fbule`/`fbuge`
  over a `fsub.s #1.0,fp0` / `fadd.s #1.0,fp0` adjust; result via
  `fmove.s fp0,d0`.  fbule/fbuge keep the trunc result when it is
  already <= / >= x — or when the compare was unordered (NaN in
  gives NaN out).
- Tst/Cmp: no FPU ops at all — sign-magnitude compares on the IEEE
  bit patterns (`add.l d0,d0` puts sign in C and magnitude in Z;
  positive IEEE singles compare like integers; the negative side
  subtracts the bit patterns which flips the order correctly,
  with a `bset #31,d0` fixup for +0 vs negative).
- Abs/Neg: pure integer `bclr`/`bchg #31,d0`.
- Open: `fmove.l fpcr,d0` + conditional `fmove.l #0x80,fpcr`
  (see findings/fpcr_open.md).

## FBcc displacement base

The `fbule`/`fbuge` word displacements are relative to the displacement
word itself (0x0a -> skips the 4-word `f*.s #imm,fp0` sequence).
