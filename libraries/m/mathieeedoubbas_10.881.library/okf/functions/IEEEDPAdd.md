---
type: Function
title: IEEEDPAdd
description: IEEE double routine at LVO -66.
---

# IEEEDPAdd — LVO -66

`double IEEEDPAdd(d0/d1 left, d2/d3 right)`

add; movem.l d0-d3,-(sp); fmove.d (sp)+,fp0; fadd.d (sp),fp0; fmove.d fp0,(sp); pop d0/d1.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
