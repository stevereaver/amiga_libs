---
type: Structure
title: XpkMode
description: Single mode descriptor "bytemode" (0x2a bytes at code+0x1b2).
---

# XpkMode

| off | field | value |
|----:|-------|-------|
| 0x00 | xm_Next | NULL (single mode) |
| 0x04 | xm_Upto | 100 |
| 0x08 | xm_Flags | 1 |
| 0x0c | xm_PackMemory | 0 |
| 0x10 | xm_UnpackMemory | 0 |
| 0x14 | xm_PackSpeed | 531 |
| 0x18 | xm_UnpackSpeed | 743 |
| 0x1c | xm_Ratio | 0 |
| 0x1e | xm_ChunkSize | 0 |
| 0x20 | xm_Description[10] | "bytemode" |
