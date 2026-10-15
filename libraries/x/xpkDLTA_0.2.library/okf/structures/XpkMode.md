---
type: Structure
title: XpkMode
description: Single mode descriptor "ByteMode" embedded at base+0x7e.
---

# XpkMode (base+0x7e)

| off | field | value |
|----:|-------|-------|
| 0x00 | xm_Next | 0 |
| 0x04 | xm_Upto | 100 |
| 0x08 | xm_Flags | 0 (unset — 0.3 has 1) |
| 0x0c | xm_PackMemory | 0 |
| 0x10 | xm_UnpackMemory | 0 |
| 0x14 | xm_PackSpeed | 0 (unset — 0.3 has 531) |
| 0x18 | xm_UnpackSpeed | 0 (unset — 0.3 has 743) |
| 0x1c | xm_Ratio | 0 |
| 0x1e | xm_ChunkSize | 0 |
| 0x20 | xm_Description[10] | "ByteMode" (InitStruct writes the two literal longs 'Byte'/'Mode') |
