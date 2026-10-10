---
type: Function
title: LibOpen
description: OpenCnt++, clears LIBF_DELEXP, returns base.
lvo: -6
registers: a6 = library base
timestamp: 2026-10-10T18:00:00Z
---

# `struct Library *LibOpen(void)`

**LVO -6** (code+0xa4) — registers `a6 = libbase`

`addi.w #1,32(a6); bclr #3,14(a6); move.l a6,d0; rts`.
Note `addi`/`bclr` forms rather than the more common `addq`/`and`.
