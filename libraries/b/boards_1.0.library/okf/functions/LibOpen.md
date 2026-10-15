---
type: Function
title: LibOpen
description: OpenCnt++, clears private expunge flag (+0x23 bit0), returns base.
lvo: -6
registers: a6 = library base
timestamp: 2026-10-10T18:00:00Z
---

# `struct Library *LibOpen(void)`

**LVO -6** (code+0x162) — registers `a6 = libbase`

`addq.w #1,32(a6); bclr #0,35(a6); move.l a6,d0; rts`.
Note the deferred-expunge flag is a private byte at +0x23 (odd
offset), not lib_Flags bit 3.
