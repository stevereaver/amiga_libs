---
type: Function
title: IEEEDPSincos
description: IEEE double routine at LVO -54.
---

# IEEEDPSincos — LVO -54

`double IEEEDPSincos(a0 cosptr, d0/d1 parm)`

sine + cosine via pointer; fsincos.d (sp),fp1:fp0; fmove.d fp1,(a0); fmove.d fp0,(sp); pop d0/d1.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
