---
type: Function
title: MapPlaneSize
description: Return the bytes-per-plane value.
lvo: -60
registers: a1 node
timestamp: 2026-10-10T19:30:00Z
---

# ``ULONG MapPlaneSize(struct CacheNode *node)``

**LVO -60**

Returns `node+20` — `BitMap.BytesPerRow * BitMap.Rows`, the size
of each plane buffer.
