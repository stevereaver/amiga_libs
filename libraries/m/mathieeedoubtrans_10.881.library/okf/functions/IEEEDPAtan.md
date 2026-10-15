---
type: Function
title: IEEEDPAtan
description: IEEE double routine at LVO -30.
---

# IEEEDPAtan — LVO -30

`double IEEEDPAtan(d0/d1 parm)`

arctangent; movem.l d0-d1,-(sp); fatan.d (sp)+,fp0; fmove.d fp0,-(sp); pop d0/d1.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
