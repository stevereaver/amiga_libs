---
type: Function
title: IEEEDPCmp
description: IEEE double routine at LVO -42.
---

# IEEEDPCmp — LVO -42

`long IEEEDPCmp(d0/d1 left, d2/d3 right)`

compare -> -1/0/+1; pure 64-bit integer sign-magnitude compare; right==0 tail-jumps into IEEEDPTst.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
