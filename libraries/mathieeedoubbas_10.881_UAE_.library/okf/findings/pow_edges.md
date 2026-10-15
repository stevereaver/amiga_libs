---
type: Finding
title: Edge-case encoding notes
description: Pow / conversion / shared-tail edge cases in mathieeedoubbas.library.
---

# Edge cases

> **Note (2026-10-15):** this 10.881 build exports only 16 vectors
> (-6..-96, ending at IEEEDPCeil) — there is NO IEEEDPPow entry point in
> the function table. The notes below describe shared-tail idioms as
> seen in related doubbas builds; treat them as background, not as
> evidence about this binary's vector set.

- Pow NaN encoding: `moveq #-1,d0; bchg d0,d0` yields 0x7fffffff
  (a quiet NaN bit pattern), then (double lib) `moveq #-1,d1` for the
  low word. Not IEEE-canonical NaN handling but deterministic.
- Pow with arg<0 only supports integral exponents; it computes
  |arg|^exp via log2/2^x and applies the sign when trunc(exp) is odd
  (tested with `fmod exp,2`).
- The reserved LVO (-24) body `moveq #0,d0; rts` doubles as a
  return-zero branch target inside Pow's arg==0,exp>0 path.
