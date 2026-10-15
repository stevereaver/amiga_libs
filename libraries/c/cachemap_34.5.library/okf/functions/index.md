---
type: Index
title: Functions
description: Exported functions and LVO entries analyzed for this library.
timestamp: 2026-10-10T19:30:00Z
---

# Functions

- [LibOpen](LibOpen.md) — LVO -6, bumps private open count at base+34.
- [LibClose](LibClose.md) — LVO -12, decrements the private count, always returns 0.
- [LibExpunge](LibExpunge.md) — LVO -18, frees plane buffers of unlocked nodes, unloads at count 0.
- [ModuleEntry](ModuleEntry.md) — LVO -24, negative word offset back to the module entry.
- [CreateMap](CreateMap.md) — LVO -30, allocates a cache map node + embedded BitMap + planes.
- [DeleteMap](DeleteMap.md) — LVO -36, unlinks and frees a node.
- [AllocMapPlanes](AllocMapPlanes.md) — LVO -42, (re)allocates the plane buffers.
- [LockMap](LockMap.md) — LVO -48, lock++ and return caller-data pointer if planes exist.
- [UnlockMap](UnlockMap.md) — LVO -54, lock--.
- [MapPlaneSize](MapPlaneSize.md) — LVO -60, returns bytes-per-plane.
- [FillMapPlanes](FillMapPlanes.md) — LVO -66, fills each plane from one bit of a mask.
- [ScaleBits](ScaleBits.md) — LVO -72, nearest-neighbour bit-stream stretch.
