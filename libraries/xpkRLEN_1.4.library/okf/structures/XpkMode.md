---
type: Structure
title: XpkMode
description: Single mode descriptor "normal" (0x2a bytes at .text+0x1f4).
resource: source/xpkRLEN_lib.s
timestamp: 2026-10-10T09:40:00Z
---

# XpkMode

One mode descriptor, immediately preceding the
[XpkInfo](XpkInfo.md) block (adjacent: 0x1f4..0x21d then
0x21e..0x275).

| off | field | value |
|----:|-------|-------|
| 0x00 | xm_Next | NULL (single mode) |
| 0x04 | xm_Upto | 100 |
| 0x08 | xm_Flags | 1 |
| 0x0c | xm_PackMemory | 0 |
| 0x10 | xm_UnpackMemory | 0 |
| 0x14 | xm_PackSpeed | 140 K/s |
| 0x18 | xm_UnpackSpeed | 1043 K/s |
| 0x1c | xm_Ratio | 45 |
| 0x1e | xm_ChunkSize | 0 |
| 0x20 | xm_Description[10] | "normal" |
