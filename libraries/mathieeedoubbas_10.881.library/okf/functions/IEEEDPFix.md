---
type: Function
title: IEEEDPFix
description: IEEE double routine at LVO -30.
---

# IEEEDPFix — LVO -30

`long IEEEDPFix(d0/d1 parm)`

double -> long; d0/d1 pushed; fmove.d (sp)+,fp0; fmove.l fp0,d0. Rounds per FPCR (0x10 = round-to-zero).

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
