---
type: Finding
title: SoftwareKernels
description: Full software transcendental engine unique to the 68040 build.
---

# Software kernels — why this build is 6188 bytes

The 68881/82 sibling is 912 bytes: every vector is a
single FPU instruction between the FFP<->IEEE converters.
The 68040 FPU omits all transcendental instructions, so
this build implements them in software — double precision
throughout, with results converted back to FFP.

Architecture:

1. **FFP->IEEE double prologue**: each vector calls
   `_SPTieee`, promotes the IEEE single to double
   (`fmoves d0,fp7` + `fmoved fp7,sp@-` round-trip tricks
   or `fmoved #const` work), computes, then hands off to
   `_SPFieee` for the range-checked FFP result.

2. **Argument reduction**: trig uses
   `floor(x * 4/pi)` (imm 0x3ff45f306dc9c883) mod 16 and
   a Cody-Waite style `r = x - n*(pi/8)` split across
   hi/lo constant pairs; exp uses
   `n = floor(x*log2e + 0.5)` / `r = x - n*ln2_hi - n*ln2_lo`.

3. **Kernel polynomials**: `_sin_poly`, `_cos_poly`,
   `_exp_poly`, `_log_core`, plus per-function rational
   approximations (atan, tanh, asin) — all minimax
   coefficients inline as `#0x...` immediates.

4. **Bit-level reconstruction**: `_exp_dbl`/`_exp_sgl`
   build `result * 2^n` by inserting n into the IEEE-64
   exponent field; `_sp_floor` is a software floor (the
   '040 lacks `fint`/`fintrz`); `_pow_int` detects
   integral exponents in SPPow and multiplies via
   repeated squaring.

5. **`fsqrts` survives**: SPSqrt (and the sqrt inside the
   SPAsin path) uses the one transcendental still in the
   '040 FPU — `fsqrts` — between the same converters as
   the FPU build.

The 0x188..0x177b code+constant region of the
reconstruction (`source/math.s`) assembles
**byte-identical** to the shipped binary.
