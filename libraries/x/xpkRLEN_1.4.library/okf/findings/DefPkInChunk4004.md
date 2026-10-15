---
type: Finding
title: xi_DefPkInChunk = 0x4004
description: Default packing chunk is 0x4004 — not a round size.
timestamp: 2026-10-10T09:40:00Z
---

# xi_DefPkInChunk = 0x4004

The default input chunk is 0x4004 (16388) bytes — 16K + 4. Probably
deliberate: the XPK chunk header carries a few bytes of bookkeeping
and a 0x4004 *input* chunk packs into a 16K buffer in the worst case
of full expansion plus token overhead. Max is 0x7fffffff (effectively
unbounded) and min is 0 — also unusual: most sublibs forbid tiny
chunks.
