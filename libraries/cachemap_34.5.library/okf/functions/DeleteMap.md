---
type: Function
title: DeleteMap
description: Unlink and free a cache map node.
lvo: -36
registers: a1 node, a6 base
timestamp: 2026-10-10T19:30:00Z
---

# ``void DeleteMap(struct CacheNode *node)``

**LVO -36**

`Forbid`; `Remove(node)`; `Permit`; frees every non-NULL plane
buffer (planeSize each, slots cleared) then the node block
(`cn_AllocSize` bytes).
