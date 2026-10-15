---
type: Finding
title: Pow / conversion edge cases
description: Verified edge-case behaviour of IEEEDPPow and the conversion vectors.
---

# Pow edge cases (oracle-verified)

- NaN encoding: `moveq #-1,d0; bchg d0,d0` yields `0x7fffffff`, then
  `moveq #-1,d1` fills the low word — a `0x7fffffff:0xffffffff` quiet
  NaN bit pattern.  Not IEEE-canonical NaN handling but deterministic —
  and it is returned for *several* distinct cases.
- arg > 0: `2^(exp * log2(arg))` via flog2/fmul.d/ftwotox.  NaN in
  either operand propagates a standard `0x7ff80000:00000000` NaN
  through the FPU ops.
- arg == ±0: classified by `fmove.d (a7)+,fp1` setting FPSR from exp:
  exp > 0 -> **branches into the reserved moveq#0/rts vector** at 0xc0
  (returns +0; d1 keeps the arg low word = 0 anyway); exp < 0 -> Lnan
  `0x7fffffff:0xffffffff` (IEEE would say +inf); exp == 0 -> 1.0;
  exp == NaN -> Lnan (fbne taken).
- arg < 0: only integral exponents allowed — fintrz.d + fcmp.d against
  the still-stacked exp; non-integral or NaN -> Lnan
  `0x7fffffff:0xffffffff`.  `fneg.x fp0,fp0` yields |arg|, result =
  |arg|^exp with bit 31 of d0 set when `fmod.s(trunc(exp),2)` != 0.
  - `pow(-0, odd)` -> **+0** (the sign of zero is lost: -0 takes the
    OLE branch, the EQ branch classifies it as zero, and the >0 path
    lands on the shared `moveq #0,d0` tail which clears the sign).
  - `pow(-2,+inf)` -> **-inf**, `pow(-2,-inf)` -> **-0**: fintrz(inf)=inf
    compares equal to itself so the "integral" test passes, and
    fmod(inf,2)=NaN is non-zero so the sign flip fires.  IEEE pow says
    +inf/+0 — genuine deviations, same as the singtrans sibling.
- `pow(-inf,3)` -> -inf cleanly through the same |arg| path.
- The reserved LVO (-24) body `moveq #0,d0; rts` doubles as the
  return-zero branch target inside Pow (fbogt 0xc0).

# Conversions

IEEEDPTieee (-102) is a real double->single conversion:
`movem.l d0-d1,-(sp); fmove.d (sp)+,fp0; fmove.s fp0,d0; rts` — the
single is returned in d0 with CCR set from the stored value
(1e300 -> 0x7f800000 inf, 1e-300 -> 0, NaN -> 0x7fc00000).

IEEEDPFieee (-108) is a real single->double conversion:
`fmove.s d0,fp0; fmove.d fp0,-(sp); pop d0/d1; rts`.  An earlier note
claimed `fmove.l d0,fp0` (integer load) and flagged it as a bug — that
was wrong, the shipped instruction is `.s` (verified in the hunk and
the disassembly; a single NaN like 0x7fffffff widens to
0x7fffffff:e0000000).
