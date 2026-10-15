---
type: Index
title: Functions
description: Exported functions and LVO entries analyzed for this library.
---

# Functions

Function table `dc.w -1, 0x008c, 0x0094, 0x0030, 0x002c, -1`
(offsets from table start 0x64):

- [LibOpen](LibOpen.md) — LVO -6, OpenCnt++
- [LibClose](LibClose.md) — LVO -12, guarded OpenCnt--, DELEXP expunge
- [LibExpunge](LibExpunge.md) — LVO -18, Remove + FreeMem
- [ExtFunc](ExtFunc.md) — LVO -24, shared `moveq #0,rts` stub
- [LibInit](LibInit.md) — InitTable init routine (not an LVO)

No public API vectors exist in this build.
