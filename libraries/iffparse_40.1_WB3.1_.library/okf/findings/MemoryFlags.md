---
type: Finding
title: Memory allocation flags
description: Which blocks get MEMF_CLEAR and which get flags 0.
timestamp: 2026-10-10T18:00:00Z
---

# Memory flags

Recovered from the `d1` setup at every `jsr a6@(-198)` (AllocMem)
and `jsr a6@(-684)` (AllocVec) site:

| allocation | call | flags |
|------------|------|-------|
| IFFHandle (40) | AllocMem | MEMF_CLEAR (0x10000) |
| root ContextNode (40) | AllocMem | MEMF_CLEAR |
| ContextNodes (40), both paths | AllocMem | 0 |
| LocalContextItem (24+data) | AllocVec | MEMF_CLEAR |
| CollectionItem (size+12) | AllocMem | 0 |
| deferred WriteBuf (size+16) | AllocMem | 0 |
| ClipboardHandle (120) | AllocVec | 0 |

Notable: none of the allocations use MEMF_PUBLIC — surprising for a
shared library, but consistent throughout the binary.  Everything
is implicitly MEMF_ANY.
