---
type: Function
title: IEEESPFix
description: IEEE single routine at LVO -30.
---

# IEEESPFix — LVO -30

`long IEEESPFix(d0 parm)`

single -> long; `fmove.s d0,fp0; fmove.l fp0,d0`.  Rounds per FPCR
rounding mode (Open leaves FPCR at 0x80 = double-precision +
round-to-nearest, so halves go to even).

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
