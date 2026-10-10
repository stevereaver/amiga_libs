---
type: Function
title: IEEESPTst
description: IEEE single routine at LVO -48.
---

# IEEESPTst — LVO -48

`long IEEESPTst(d0 parm)`

test -> -1/0/+1; add.l d0,d0 to shift sign into carry; branches to shared -1/+1 tails inside IEEESPCmp. +0 and -0 both return 0.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
