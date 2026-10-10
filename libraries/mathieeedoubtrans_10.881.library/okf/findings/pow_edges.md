---
type: Finding
title: Edge-case encoding notes
description: Pow / conversion / shared-tail edge cases in mathieeedoubtrans.library.
---

# Edge cases

- Pow NaN encoding: `moveq #-1,d0; bchg d0,d0` yields 0x7fffffff
  (a quiet NaN bit pattern), then (double lib) `moveq #-1,d1` for the
  low word. Not IEEE-canonical NaN handling but deterministic.
- Pow with arg<0 only supports integral exponents; it computes
  |arg|^exp via log2/2^x and applies the sign when trunc(exp) is odd
  (tested with `fmod exp,2`).
- The reserved LVO (-24) body `moveq #0,d0; rts` doubles as a
  return-zero branch target inside Pow's arg==0,exp>0 path.

IEEEDPTieee is a real conversion (fmove.d in, fmove.s out). IEEEDPFieee
uses `fmove.l d0,fp0` -- d0 is loaded as a LONG INTEGER and converted to
double, so a single-precision bit pattern passed in d0 is reinterpreted
as an integer. Verbatim-preserving note: this appears to be a bug in the
shipped code, or the argument convention differs from the documented
single-float convention.
