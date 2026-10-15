---
type: Function
title: LibNull
description: IEEE single routine at LVO -24.
---

# LibNull — LVO -24

`(reserved/ExtFunc) -> d0 = 0`

`moveq #0,d0; rts` at hunk+0xb6.  Also serves as the shared "return 0"
tail for Close (opencnt still nonzero / DELEXP clear) and for the
deferred-Expunge path.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
