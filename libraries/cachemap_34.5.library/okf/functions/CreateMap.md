---
type: Function
title: CreateMap
description: Allocate a cache map node with embedded BitMap and plane buffers.
lvo: -30
registers: d0 width, d1 height, d2 depth, d3 dataSize, d4 flags, a6 base
timestamp: 2026-10-10T19:30:00Z
---

# ``struct CacheNode *CreateMap(ULONG width, ULONG height, ULONG depth, ULONG dataSize, ULONG flags)``

**LVO -30**

- `dataSize` must be a multiple of 4 or NULL is returned.
- Allocates `36 + dataSize + 4*depth` bytes with AllocMem flags
  `0x00010001` (MEMF_CLEAR + undocumented bit 0).
- Stores allocSize(+8), dataSize(+12), depth(+18), flags(+24).
- `InitBitMap(&node->bitmap, depth, width, height)` at node+28+dataSize;
  `planeSize = BytesPerRow * Rows` stored at +20.
- Calls AllocMapPlanes (LVO -42 logic) for the depth buffers;
  on failure frees the node and returns 0.
- `Forbid/AddHead/Permit` onto the library list; returns the node.
