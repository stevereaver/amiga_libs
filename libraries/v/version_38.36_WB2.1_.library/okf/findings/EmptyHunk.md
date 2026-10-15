---
type: Finding
title: Empty second hunk
description: The binary carries a zero-length code hunk after hunk 0.
timestamp: 2026-10-10T19:00:00Z
---

# Empty second hunk

The hunk table declares 2 hunks; hunk 1 is a `HUNK_CODE` with length
0 followed immediately by `HUNK_END`.  Harmless artifact of the
original link.  ld emits no empty sections, so `source/fixup.py`
rewrites the header's hunk table and appends the empty hunk-1 record
after link — the final file is byte-identical.
