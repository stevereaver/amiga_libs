---
type: Function
title: IEEESPCeil
description: IEEE single routine at LVO -96.
---

# IEEESPCeil — LVO -96

`float IEEESPCeil(d0 parm)`

ceil; `fintrz.s d0,fp0` (fp0 = trunc(x)); `fcmp.s d0,fp0`; `fbuge`
keeps fp0 when trunc(x) >= x (or unordered/NaN), else `fadd.s #1.0,fp0`;
result `fmove.s fp0,d0`.  Mirror of IEEESPFloor.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
