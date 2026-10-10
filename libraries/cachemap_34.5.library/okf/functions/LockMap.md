---
type: Function
title: LockMap
description: Increment the lock and return the caller-data pointer if usable.
lvo: -48
registers: a1 node
timestamp: 2026-10-10T19:30:00Z
---

# ``APTR LockMap(struct CacheNode *node)``

**LVO -48**

`node->lock++`; returns `node+28` (caller-data area) when
`bm_Planes[0]` is non-NULL, else 0.  The lock is incremented even
when 0 is returned.
