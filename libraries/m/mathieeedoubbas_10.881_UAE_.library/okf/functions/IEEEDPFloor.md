---
type: Function
title: IEEEDPFloor
description: IEEE double routine at LVO -90.
---

# IEEEDPFloor — LVO -90

`double IEEEDPFloor(d0/d1 parm)`

floor; fp1=x; fp0=fintrz.d(x); fcmp.x fp0 vs fp1; if fp0>x subtract 1.0 (fsub.s #1).

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
