---
type: Finding
title: Rebuild deviations
timestamp: 2026-10-10T20:10:00Z
---

# Rebuild deviations

The rebuilt `source/dsp3210.library` is not byte-identical (expected):

- Code hunk 0x4d4 vs original 0x43c — the relocator is the largest C
  reconstruction so far and gcc's codegen is bulkier than the
  hand-tuned original.
- The `×18` table strides compile to shift/add sequences instead of
  `mulu` — semantics identical (low-word multiply).
- The external-symbol byte-compare is inlined differently; `Streq`
  exists as a helper in source but may be folded.
- Pass-1 copies use the same byte loop (`move.b (a1)+,(a0)+`) the
  original uses rather than CopyMem — preserved.

Byte-identical: RomTag fields (including flags=0 and the post-cookie
idstring pointer), module entry opcode, name and id strings, and the
6-entry function-table shape.
