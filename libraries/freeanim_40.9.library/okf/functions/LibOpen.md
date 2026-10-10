---
type: Function
title: LibOpen
description: OpenCnt++, returns the library base.
lvo: -6
registers: a6 = library base
timestamp: 2026-10-10T18:00:00Z
---

# `struct Library *LibOpen(void)`

**LVO -6** (code+0xf0) — registers `a6 = libbase`

`addq.w #1,32(a6); move.l a6,d0; rts` — increments OpenCnt and
returns the base.  Does not clear DELEXP (unlike _asl/boards which
clear it on open).
