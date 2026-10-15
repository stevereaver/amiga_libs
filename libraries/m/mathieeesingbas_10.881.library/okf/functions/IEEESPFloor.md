---
type: Function
title: IEEESPFloor
description: IEEE single routine at LVO -90.
---

# IEEESPFloor — LVO -90

`float IEEESPFloor(d0 parm)`

floor; `fintrz.s d0,fp0` (fp0 = trunc(x)); `fcmp.s d0,fp0`; `fbule`
keeps fp0 when trunc(x) <= x (or unordered/NaN), else `fsub.s #1.0,fp0`;
result `fmove.s fp0,d0`.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
