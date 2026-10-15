---
type: Function
title: IEEEDPPow
description: IEEE double routine at LVO -90.
---

# IEEEDPPow — LVO -90

`double IEEEDPPow(d0/d1 arg, d2/d3 exp)`

arg^exp; movem.l d0-d3 pushes arg+exp; same log2/mul/2^x scheme as IEEESPPow with doubles. NaN = 0x7fffffff/0xffffffff; exp==0 -> 1.0; exp>0,arg==0 -> +0 (d1 keeps arg lo bits).

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
