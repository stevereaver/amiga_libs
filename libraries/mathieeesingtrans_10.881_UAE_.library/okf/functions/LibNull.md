---
type: Function
title: LibNull
description: IEEE single routine at LVO -24.
---

# LibNull — LVO -24

`(reserved/ExtFunc) -> d0 = 0`

moveq #0,d0; rts. Also used as a branch target inside Pow's zero-argument path to return +0.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
