---
type: Structure
title: FreeAnimBase (library base)
description: Library base layout, 0x26 bytes.
timestamp: 2026-10-10T18:00:00Z
---

# FreeAnimBase

| offset | field | evidence |
|-------:|-------|----------|
| 0x00 | `struct Library` | InitStruct sets type/name/flags/ver/rev/id |
| 0x22 | `ULONG fa_SegList` | stored by init (`move.l a0,34(a0)`), read by expunge |

dataSize 0x26 — base ends at 0x26.
