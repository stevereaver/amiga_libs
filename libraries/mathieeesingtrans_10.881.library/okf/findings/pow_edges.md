---
type: Finding
title: Pow / shared-tail edge cases
description: Verified edge-case behaviour of IEEESPPow and the shared code tails.
---

# Pow edge cases (oracle-verified)

- NaN encoding: `moveq #-1,d0; bchg d0,d0` yields `0x7fffffff`
  (a quiet NaN bit pattern).  Not IEEE-canonical NaN handling but
  deterministic — and it is returned for *several* distinct cases.
- arg > 0: `2^(exp * log2(arg))` via flog2/fmul/ftwotox.  NaN in either
  operand propagates a standard `0x7fc00000` NaN through the FPU ops.
- arg == ±0: classified by `fmove.s d1,fp1` setting FPSR from exp:
  exp > 0 -> **branches into the reserved moveq#0/rts vector** at 0xd4
  (returns +0); exp < 0 -> Lnan `0x7fffffff` (IEEE would say +inf);
  exp == 0 -> 1.0f; exp == NaN -> Lnan `0x7fffffff` (fbne taken).
- arg < 0 (incl. -0.0 first negated): only integral exponents allowed —
  fintrz + fcmp; non-integral or NaN -> Lnan `0x7fffffff`.
  Result = |arg|^exp with bit 31 set when `fmod(trunc(exp),2)` != 0.
  - `pow(-0, odd)` -> **+0** (the sign of zero is lost in the fneg).
  - `pow(-2,+inf)` -> **-inf**, `pow(-2,-inf)` -> **-0**: fintrz(inf)=inf
    compares equal to itself so the "integral" test passes, and
    fmod(inf,2)=NaN is non-zero so the sign flip fires.  IEEE pow says
    +inf/+0 — genuine deviations.
- The reserved LVO (-24) body `moveq #0,d0; rts` doubles as the
  return-zero branch target inside Pow (fbogt 0xd4) — the same byte
  trick the singbas sibling uses for its own returns.

# Shared stub

Both IEEESPTieee (-102) and IEEESPFieee (-108) vector slots point at the
same bare `rts` at 0x1a4 — which is also the return instruction of
IEEESPSincos.  Single->trans and trans->single are the identity.
