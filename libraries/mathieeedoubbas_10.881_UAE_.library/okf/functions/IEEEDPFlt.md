---
type: Function
title: IEEEDPFlt
description: IEEE double routine at LVO -36.
---

# IEEEDPFlt — LVO -36

`double IEEEDPFlt(d0 integer)`

long -> double; fmove.l d0,fp0; fmove.d fp0,-(sp); pop d0/d1.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
