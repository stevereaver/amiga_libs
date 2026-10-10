---
type: Function
title: FillMapPlanes
description: Fill each plane buffer with all-ones or all-zeros from a bit mask.
lvo: -66
registers: d0 mask, a1 node
timestamp: 2026-10-10T19:30:00Z
---

# ``void FillMapPlanes(ULONG mask, struct CacheNode *node)``

**LVO -66**

`node->lock++`, then for each plane i (0 .. depth-1): the i-th
source bit (`d0 >> i`) is shifted out; when set the plane buffer is
filled with `0xFFFFFFFF`, otherwise `0x00000000` — planeSize/4
longwords plus planeSize&3 trailing bytes.  NULL plane entries are
skipped.  `node->lock--` at the end.
