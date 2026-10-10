---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-10
- Parsed RomTag/InitTable from the binary (word-offset functab,
  11 entries incl. negative -24 back to module entry).  Decoded all
  vectors: CacheMap = node allocator with embedded BitMap; -30 calls
  InitBitMap via graphics.library opened at init; -72 is a
  Bresenham bit-stream replicator.  Wrote C reconstruction with
  two-pass functab; `make` produces a valid library.  Populated okf/.
