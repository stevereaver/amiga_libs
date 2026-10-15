---
type: Structure
title: Jump vectors
description: NegSize vector region built by AUTOINIT for mathieeesingbas.library.
---

# Jump vectors (mathieeesingbas.library)

AUTOINIT expands the word-offset table into the standard negative-offset
jump region below the base: `jmp abs.l` (or PC-relative jump) at -6, -12,
-18, -24, then -30..-52 for the 12 public functions.

Resolved LVOs (canonical NDK fd13 file):

| LVO | function |
|-----|----------|
| -6 | LibOpen |
| -12 | LibClose |
| -18 | LibExpunge |
| -24 | LibNull |
| -30 | IEEESPFix |
| -36 | IEEESPFlt |
| -42 | IEEESPCmp |
| -48 | IEEESPTst |
| -54 | IEEESPAbs |
| -60 | IEEESPNeg |
| -66 | IEEESPAdd |
| -72 | IEEESPSub |
| -78 | IEEESPMul |
| -84 | IEEESPDiv |
| -90 | IEEESPFloor |
| -96 | IEEESPCeil |
