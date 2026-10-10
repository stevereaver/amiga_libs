---
type: Structure
title: HunkMap
description: Single code hunk, 0x278 bytes, 14 RELOC32 entries.
timestamp: 2026-10-10T09:40:00Z
---

# Hunk map

One code hunk (0x278 bytes) + HUNK_RELOC32 + HUNK_END.

| .text off | content |
|-----------|---------|
| 0x00 | `moveq #-1,d0 / rts` entry |
| 0x04 | RomTag (RT_ENDSKIP → 0x278, module end) |
| 0x1e | InitTable (dataSize 0x2a) |
| 0x2e | function table (word offsets, -1 markers) |
| 0x46 | InitStruct data |
| 0x66 | "xpkRLEN.library\0" |
| 0x76 | "xpkRLEN 1.4 (1.12.2010)\r\n\0" + pad |
| 0x90 | strings: RLEN / Run Length / description (to 0xd3) |
| 0xd4 | LibInit |
| 0xdc | LibOpen |
| 0xea | LibClose (falls through to Expunge) |
| 0xf8 | LibExpunge |
| 0x12e | LibNull stub (`moveq #0/rts`) |
| 0x132 | XpksUnpackChunk |
| 0x158 | XpksPackerInfo |
| 0x160 | XpksPackChunk (encoder) |
| 0x1f4 | XpkMode "normal" (0x2a) |
| 0x21e | XpkInfo (0x58) |
| 0x276 | pad word, end |

Code comes before the descriptor blocks; strings before the code.
The rebuild is byte-identical through +0x0c (RT_ENDSKIP value) and
holds the same tables/descriptors at different offsets.
