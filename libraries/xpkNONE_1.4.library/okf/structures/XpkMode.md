---
type: Structure
title: XpkMode
description: Single mode descriptor "normal" (0x2a bytes at .text+0x184).
resource: source/xpkbase.h
timestamp: 2026-10-10T19:45:00Z
---

# XpkMode

One mode descriptor, immediately preceding the
[XpkInfo](XpkInfo.md) block (adjacent in the hunk: 0x184..0x1ad then
0x1ae..0x205).

| off | field | value |
|----:|-------|-------|
| 0x00 | xm_Next | NULL (single mode) |
| 0x04 | xm_Upto | 100 |
| 0x08 | xm_Flags | 1 |
| 0x0c | xm_PackMemory | 0 |
| 0x10 | xm_UnpackMemory | 0 |
| 0x14 | xm_PackSpeed | 1918 K/s |
| 0x18 | xm_UnpackSpeed | 2477 K/s |
| 0x1c | xm_Ratio | 0 (no compression) |
| 0x1e | xm_ChunkSize | 0 |
| 0x20 | xm_Description[10] | "normal" |
