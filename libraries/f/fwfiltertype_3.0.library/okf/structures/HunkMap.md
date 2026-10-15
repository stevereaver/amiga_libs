---
type: Structure
title: HunkMap
description: Single code hunk, 0x1b4 bytes, 17 RELOC32 entries.
timestamp: 2026-10-10T19:15:00Z
---

# Hunk map

One code hunk (HUNK_CODE, 0x6d longs = 436 bytes) + HUNK_RELOC32 (17
entries) + HUNK_END. No data/bss hunks.

| .text off | content |
|-----------|---------|
| 0x00 | `moveq #0,d0 / rts` entry |
| 0x04 | RomTag (name .text+0x1e, idstr .text+0x39, init .text+0x7e) |
| 0x1e | "fwfiltertype.library\0" |
| 0x33 | "$VER: fwfiltertype.library 3.0 (6.8.93)\n\0" |
| 0x55 | "Copyright \xa9 1993 SoftWood, Inc.\n\0" |
| 0x7e | InitTable (dataSize 0x28) |
| 0x8e | function table (6 longs + -1L) |
| 0xaa | InitStruct data |
| 0xb2 | LibOpen |
| 0xbc | LibClose |
| 0xd2 | LibExpunge (+ GetSegList helper at 0x144) |
| 0x118 | LibNull (shared by -24/-36) |
| 0x150 | LibInit |
| 0x150+ | FwFilterType |

All 17 relocations are pointer longs (romtag fields, table entries,
datatab pointers, Expunge's jsr target). The rebuilt image reproduces
the same layout; code-hunk size differs (gcc codegen).
