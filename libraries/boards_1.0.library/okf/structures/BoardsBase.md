---
type: Structure
title: BoardsBase (library base)
description: Library base layout, 0x2c bytes.
timestamp: 2026-10-10T18:00:00Z
---

# BoardsBase

| offset | field | evidence |
|-------:|-------|----------|
| 0x00 | `struct Library` | InitStruct fields |
| 0x22 | `UBYTE` unused | within dataSize, never accessed |
| 0x23 | `UBYTE ExpungeReq` bit0 | `bclr #0,35(a6)` in Open; `bset`/`btst` in Expunge/Close |
| 0x24 | `struct ExecBase *SysBase` | `move.l a6,36(a5)` in init; read by Expunge |
| 0x28 | `ULONG SegList` | `move.l a0,40(a5)` in init; returned by Expunge |

dataSize 0x2c.  Two further cells live in the code hunk (not the
base): libbase (dead store) and the expname.library base.
