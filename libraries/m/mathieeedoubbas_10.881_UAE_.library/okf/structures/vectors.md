---
type: Structure
title: Jump vectors
description: NegSize vector region built by AUTOINIT for mathieeedoubbas.library.
---

# Jump vectors (mathieeedoubbas.library)

AUTOINIT expands the word-offset table into the standard negative-offset
jump region below the base: `jmp abs.l` at -6, -12,
-18, -24, then -30..-96 for the 12 public functions.

Resolved LVOs (canonical NDK fd13 file):

| LVO | function |
|-----|----------|
| -6 | LibOpen |
| -12 | LibClose |
| -18 | LibExpunge |
| -24 | LibNull |
| -30 | IEEEDPFix |
| -36 | IEEEDPFlt |
| -42 | IEEEDPCmp |
| -48 | IEEEDPTst |
| -54 | IEEEDPAbs |
| -60 | IEEEDPNeg |
| -66 | IEEEDPAdd |
| -72 | IEEEDPSub |
| -78 | IEEEDPMul |
| -84 | IEEEDPDiv |
| -90 | IEEEDPFloor |
| -96 | IEEEDPCeil |
