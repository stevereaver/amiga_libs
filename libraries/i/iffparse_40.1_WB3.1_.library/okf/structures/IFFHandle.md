---
type: Structure
title: IFFHandle (internal)
description: 40-byte IFFHandle; public fields plus private internals.
resource: source/iffbase.h
timestamp: 2026-10-10T18:00:00Z
---

# IFFHandle internals

`AllocIFF` allocates **40 bytes** (`AllocMem(40, MEMF_CLEAR)`); the
NDK `struct IFFHandle` documents only the first fields.  Layout as
used by the binary:

| offset | field | notes |
|-------:|-------|-------|
| 0x00 | `ULONG iff_Stream` | stream cookie: BPTR (DOS) or ClipboardHandle* |
| 0x04 | `ULONG iff_Flags` | IFFF_* + private bits (see below) |
| 0x08 | `LONG  iff_Depth` | context depth |
| 0x0c | `struct MinList iff_ContextStack` | top context node at head; root at tail |
| 0x18 | `struct MinList iff_WriteList` | deferred-write buffers for non-seekable streams |
| 0x24 | `struct Hook *iff_Hook` | stream hook (set by InitIFF@+0x24) |

Evidence: `InitIFF` stores `a1` at +0x24 and `d0` at +0x04;
`AllocIFF` initialises MinLists at +0x0c and +0x18 (calls to the
shared init routine at 0x1964).

## Private flag bits

- `0x00010000` IFFF_FIRSTCHUNK — first chunk pending/validating
- `0x00020000` IFFF_PENDINGPOP — pop current context on next step

## Root context node

AllocIFF also allocates a 40-byte root [ContextNode](ContextNode.md)
(MEMF_CLEAR); its `cn_LCIList` is the property store and its
`cn_ID` is 0.
