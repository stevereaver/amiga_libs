---
type: Structure
title: HunkMap
description: Single code hunk, 0x20c bytes, 17 RELOC32 entries.
timestamp: 2026-10-10T09:20:00Z
---

# Hunk map

One code hunk (0x20c bytes) + HUNK_RELOC32 + HUNK_END. No data/bss
hunks.

| .text off | content |
|-----------|---------|
| 0x00 | `moveq #0,d0 / rts` entry — also the shared "return 0" vector |
| 0x04 | RomTag (RT_ENDSKIP → 0x00) |
| 0x1e | "xpkNONE.library\0" |
| 0x2e | "$VER: xpkNONE V1.5 (1 Oct 2013) by Dirk Stoecker\r\n\0" + pad |
| 0x62 | InitTable (dataSize 0x26) |
| 0x72 | InitStruct data |
| 0x92 | function table (word offsets, -1 marker/terminator) |
| 0xaa | LibInit (3 insns: store seglist, rts) |
| 0xb2 | LibOpen |
| 0xc0 | LibClose (falls through to Expunge) |
| 0xd2 | LibExpunge |
| 0x110 | XpksPackerInfo |
| 0x118 | XpksPackChunk |
| 0x11c | XpksUnpackChunk |
| 0x13c | XpkInfo (0x58) |
| 0x194 | XpkMode "normal" (0x2a) |
| 0x1be | strings: NoPacker / description / Writing / Reading / Wrote / Read |

The rebuilt image is byte-identical through the InitTable/data region
(+.text+0x68); ordering of the functab/code/descriptor blocks below
differs (object link order), and compiled code is larger (0x230 total).
