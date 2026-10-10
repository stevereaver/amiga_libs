---
type: Function
title: LibOpen
description: OpenCnt++, clears private expunge flag (+0x2e bit3), returns base.
lvo: -6
registers: a6 = library base
timestamp: 2026-10-10T18:00:00Z
---

# `struct Library *LibOpen(void)`

**LVO -6** — registers `a6 = libbase`

`addq.w #1,32(a6); bclr #3,46(a6); move.l a6,d0; rts`.
