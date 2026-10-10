---
type: Structure
title: FantasiaBase (library base)
description: Library base layout, 0x30 bytes.
timestamp: 2026-10-10T18:00:00Z
---

# FantasiaBase

| offset | field | evidence |
|-------:|-------|----------|
| 0x00 | `struct Library` | InitStruct fields |
| 0x22 | `struct ExecBase *SysBase` | `move.l a6,34(a5)` in init; expunge uses it for all exec calls |
| 0x26 | `struct Library *DOSBase` | `move.l d0,38(a5)` after OpenLibrary; closed in expunge |
| 0x2a | `ULONG SegList` | `move.l a0,42(a5)` in init; returned by expunge |
| 0x2e | `UBYTE ExpungeReq` bit3 | `bclr/bset/btst #3,46(...)` — Close tests it via a5 (bug) |
| 0x2f | pad | dataSize 0x30 |

dataSize 0x30.
