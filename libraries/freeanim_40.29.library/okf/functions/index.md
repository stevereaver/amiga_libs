---
type: Index
title: Functions
description: Exported functions and LVO entries analyzed for this library.
---

# Functions

The function table is `dc.w -1, 0x000c, 0x000c, 0x000c, 0x000c, -1`:
all four system vectors land on the shared stub at code+0x66.

- [LibNull](LibNull.md) — LVO -6/-12/-18/-24 shared `moveq #0,rts`
- [LibOpen](LibOpen.md) — LVO -6 (stub, returns 0)
- [LibClose](LibClose.md) — LVO -12 (stub, returns 0)
- [LibExpunge](LibExpunge.md) — LVO -18 (stub, returns 0)
- [ExtFunc](ExtFunc.md) — LVO -24 (stub, returns 0)
