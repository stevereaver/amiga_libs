---
type: Structure
title: CacheNode
description: Variable-size node: 28-byte header + caller data + embedded BitMap.
timestamp: 2026-10-10T19:30:00Z
---

# struct CacheNode — variable size

| off | field |
|-----|-------|
| 0 | `ln_Succ`/`ln_Pred` (8; only used for list linkage) |
| 8 | `LONG` allocSize — total AllocMem size |
| 12 | `LONG` dataSize — caller data bytes at +28 |
| 16 | `UWORD` lock count |
| 18 | `UWORD` depth (BitMap depth / plane count) |
| 20 | `LONG` planeSize = BytesPerRow*Rows |
| 24 | `LONG` flags — AllocMem flags for plane buffers |
| 28 | `dataSize` bytes caller data (must be multiple of 4) |
| 28+dataSize | `struct BitMap` — 8-byte header + `depth` plane pointers |

Node allocation = `36 + dataSize + 4*depth` =
28 (header) + dataSize + 8 (BitMap header) + 4*depth.
