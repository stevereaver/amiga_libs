---
type: Function
title: IEEESPPow
description: IEEE single routine at LVO -90.
---

# IEEESPPow — LVO -90

`float IEEESPPow(d1 exp, d0 arg)`

arg^exp; arg>0: 2^(exp*log2(arg)) via flog2/fmul/ftwotox. arg==0: +0 (exp>0), 1.0 (exp==0), NaN 0x7fffffff (exp<0). arg<0: |arg|^trunc(exp) with sign when trunc(exp) odd; NaN when exp non-integral.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
