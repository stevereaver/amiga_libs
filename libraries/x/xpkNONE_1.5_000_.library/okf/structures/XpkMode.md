---
type: Structure
title: XpkMode
description: Single mode descriptor "normal" (0x2a bytes at .text+0x194).
resource: source/xpkNONE_lib.s
timestamp: 2026-10-10T09:20:00Z
---

# XpkMode

One mode descriptor; in the original it follows the code and precedes
the string pool (the [XpkInfo](XpkInfo.md) block at .text+0x13c points
back at it).

| off | field | value |
|----:|-------|-------|
| 0x00 | xm_Next | NULL (single mode) |
| 0x04 | xm_Upto | 100 |
| 0x08 | xm_Flags | 1 |
| 0x0c | xm_PackMemory | 0 |
| 0x10 | xm_UnpackMemory | 0 |
| 0x14 | xm_PackSpeed | 1450 K/s (was 1918 in 1.4) |
| 0x18 | xm_UnpackSpeed | 1450 K/s (was 2477 in 1.4) |
| 0x1c | xm_Ratio | 0 (no compression) |
| 0x1e | xm_ChunkSize | 0 |
| 0x20 | xm_Description[10] | "normal" |
