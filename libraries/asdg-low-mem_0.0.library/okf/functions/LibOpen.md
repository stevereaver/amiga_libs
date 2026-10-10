---
type: Function
title: LibOpen
description: Bumps private open count, keeps exec's lib_OpenCnt at 0.
lvo: -6
registers: a6 base
timestamp: 2026-10-10T19:00:00Z
---

# ``struct Library *LibOpen(void)``

**LVO -6** — `a6` = library base

`addq.w #1,56(a6)` (private count at base+0x38),
`clr.w 32(a6)` (`lib_OpenCnt` is forced back to 0 every Open),
returns `a6`.

The deliberate zeroing of `lib_OpenCnt` means the standard
expunge-on-zero mechanism can never trigger; the private counter
at +0x38 is the real one.
