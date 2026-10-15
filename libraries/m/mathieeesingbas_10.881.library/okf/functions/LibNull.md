---
type: Function
title: LibNull
description: IEEE single routine at LVO -24.
---

# LibNull — LVO -24

`(reserved/ExtFunc) -> d0 = 0`

`moveq #0,d0; rts` at code+0xb6.  The same two instructions are also
Close's "still open" return and Expunge's deferred-expunge return —
three roles, one body.

LVO definitions verified against the canonical NDK fd file
`/opt/amiga/m68k-amigaos/ndk/lib/fd13/`.
