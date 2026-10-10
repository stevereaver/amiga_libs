---
type: Function
title: IEEESPCmp
description: IEEE single routine at LVO -42.
---

# IEEESPCmp — LVO -42

`long IEEESPCmp(d0 left, d1 right)`

compare -> -1/0/+1; pure integer sign-magnitude compare on the single-format bit patterns; falls through into IEEESPTst when right==0 (shared code tails).

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
