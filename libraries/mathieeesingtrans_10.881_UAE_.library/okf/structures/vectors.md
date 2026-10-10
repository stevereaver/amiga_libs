---
type: Structure
title: Jump vectors
description: NegSize vector region built by AUTOINIT for mathieeesingtrans.library.
---

# Jump vectors (mathieeesingtrans.library)

AUTOINIT expands the word-offset table into the standard negative-offset
jump region below the base: `jmp abs.l` (or PC-relative jump) at -6, -12,
-18, -24, then -30..-62 for the 17 public functions.

Resolved LVOs (canonical NDK fd13 file):

| LVO | function |
|-----|----------|
| -6 | LibOpen |
| -12 | LibClose |
| -18 | LibExpunge |
| -24 | LibNull |
| -30 | IEEESPAtan |
| -36 | IEEESPSin |
| -42 | IEEESPCos |
| -48 | IEEESPTan |
| -54 | IEEESPSincos |
| -60 | IEEESPSinh |
| -66 | IEEESPCosh |
| -72 | IEEESPTanh |
| -78 | IEEESPExp |
| -84 | IEEESPLog |
| -90 | IEEESPPow |
| -96 | IEEESPSqrt |
| -102 | IEEESPTieee |
| -108 | IEEESPFieee |
| -114 | IEEESPAsin |
| -120 | IEEESPAcos |
| -126 | IEEESPLog10 |
