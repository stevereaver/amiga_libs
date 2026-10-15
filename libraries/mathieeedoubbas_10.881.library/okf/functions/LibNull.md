---
type: Function
title: LibNull
description: IEEE double routine at LVO -24.
---

# LibNull — LVO -24

`(reserved/ExtFunc) -> d0 = 0`

moveq #0,d0; rts. The same two words double as Close's "still open"
return path and Expunge's deferred (busy) return path.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
