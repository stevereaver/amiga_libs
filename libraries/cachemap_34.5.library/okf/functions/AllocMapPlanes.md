---
type: Function
title: AllocMapPlanes
description: Allocate the depth plane buffers of a node.
lvo: -42
registers: a1 node, a6 base
timestamp: 2026-10-10T19:30:00Z
---

# ``APTR AllocMapPlanes(struct CacheNode *node)``

**LVO -42**

For i in 0 .. depth-1: `bm_Planes[i] = AllocMem(planeSize, flags)`;
the loop stops on the first failure (the array entry receives the
NULL), then all non-NULL buffers are freed and 0 is returned.
On success returns `node+28` (the caller-data area).
