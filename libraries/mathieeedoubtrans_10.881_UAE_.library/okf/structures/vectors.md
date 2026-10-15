---
type: Structure
title: Jump vectors
description: NegSize vector region built by AUTOINIT for mathieeedoubtrans.library.
---

# Jump vectors (mathieeedoubtrans.library)

AUTOINIT expands the word-offset table into the standard negative-offset
jump region below the base: `jmp abs.l` (or PC-relative jump) at -6, -12,
-18, -24, then -30..-126 for the 17 public functions.

Resolved LVOs (canonical NDK fd13 file):

| LVO | function |
|-----|----------|
| -6 | LibOpen |
| -12 | LibClose |
| -18 | LibExpunge |
| -24 | LibNull |
| -30 | IEEEDPAtan |
| -36 | IEEEDPSin |
| -42 | IEEEDPCos |
| -48 | IEEEDPTan |
| -54 | IEEEDPSincos |
| -60 | IEEEDPSinh |
| -66 | IEEEDPCosh |
| -72 | IEEEDPTanh |
| -78 | IEEEDPExp |
| -84 | IEEEDPLog |
| -90 | IEEEDPPow |
| -96 | IEEEDPSqrt |
| -102 | IEEEDPTieee |
| -108 | IEEEDPFieee |
| -114 | IEEEDPAsin |
| -120 | IEEEDPAcos |
| -126 | IEEEDPLog10 |
