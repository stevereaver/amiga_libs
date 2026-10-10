---
type: Finding
title: RebuildDeviations
description: Where the reconstruction differs from the shipped binary.
timestamp: 2026-10-10T20:00:00Z
---

# Rebuild deviations

- Code hunk is 0x374 bytes vs the original's 0x318 (GCC codegen);
  the `.data` hunk is byte-layout identical (same 0x78 bytes,
  same field offsets).
- GCC emits a PC-indexed jump table for the tag switch just like
  the original hand-written one.
- All API/tag names are reconstructed; the binary exports none.
