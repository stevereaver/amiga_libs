---
type: Structure
title: AslShimBase (library base)
description: Library base layout, 0x2e bytes.
timestamp: 2026-10-10T18:00:00Z
---

# AslShimBase

| offset | field | evidence |
|-------:|-------|----------|
| 0x00 | `struct Library` | InitStruct fields |
| 0x22 | `APTR sh_OpenFunc` | read by relay tail (`movea.l 34(a6),a0`); **never written by the library** |
| 0x26 | `STRPTR sh_RealName` | InitStruct INITLONG(0x26) = `_libname+1` ("asl.library") |
| 0x2a | `ULONG sh_SegList` | init routine `move.l a0,42(a5)`; read by expunge |

dataSize 0x2e.
