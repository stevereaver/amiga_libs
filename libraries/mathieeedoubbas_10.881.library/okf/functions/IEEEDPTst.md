---
type: Function
title: IEEEDPTst
description: IEEE double routine at LVO -48.
---

# IEEEDPTst — LVO -48

`long IEEEDPTst(d0/d1 parm)`

test -> -1/0/+1; add.l d0,d0 shifts sign into carry; lo word checked when hi==0. +0/-0 return 0.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
