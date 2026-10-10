---
type: Structure
title: HunkMap
description: Single code hunk, 0x288 bytes, 23 RELOC32 entries.
timestamp: 2026-10-10T19:45:00Z
---

# Hunk map

One code hunk (HUNK_CODE 0xa2 longs = 0x288 bytes) + HUNK_RELOC32 +
HUNK_END. No data/bss hunks.

| .text off | content |
|-----------|---------|
| 0x00 | `moveq #-1,d0 / rts` entry |
| 0x04 | function table (10 longs + -1L) |
| 0x30–0x53 | zero padding |
| 0x54 | InitStruct data |
| 0x74 | InitTable (dataSize 0x2a) |
| 0x84 | RomTag |
| 0x9e | "xpkNONE.library\0" |
| 0xae | "xpkNONE 1.4 (19.07.1998)\r\n\0" |
| 0xca | LibNull stub |
| 0xce | LibExpunge |
| 0x114 | LibClose |
| 0x130 | LibOpen |
| 0x13e | _LibInit |
| 0x17c | XpksPackerInfo |
| 0x184 | XpkMode "normal" (0x2a) |
| 0x1ae | XpkInfo (0x58) |
| 0x206 | strings: NONE/NoPacker/description/Writing/Reading/Wrote/Read |
| 0x25c | XpksPackChunk |
| 0x260 | XpksUnpackChunk |

The rebuilt image reproduces this layout exactly through +0xca; code
offsets below that differ (gcc codegen).
