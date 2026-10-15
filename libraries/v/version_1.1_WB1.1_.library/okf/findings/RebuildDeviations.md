---
type: Finding
title: Rebuild deviations (historical)
description: >-
  Deviations of the earlier C reconstruction.  SUPERSEDED:
  source/version.s + fixup.py now rebuilds the file byte-identically
  (md5 bc46a12754951613df55a474cf87e5b5).
timestamp: 2026-10-15T00:00:00Z
---

# Rebuild deviations (C model — superseded)

The canonical build is `source/version.s` + `source/fixup.py`,
byte-identical to the shipped binary including the empty second CODE
hunk record and descending RELOC32 order.  The notes below applied to
the earlier C reconstruction (`make cmodel`): GCC wraps vectors in a6
save/restore (longer code), and stock ld cannot emit the empty second
hunk.  All table regions were already byte-identical.
- **WB1.1 buggy Expunge**: passes the lib base in a0 (Remove takes a1) and computes the free size via `move.l $10(a5)` — the packed {negSize,posSize} longword — then `add.l $12(a5)` (pos) on top.  Oracle shows `FreeMem(lib-(neg<<16|pos), packed+pos)` = wild pointer+size.  Also a vestigial `byte@lib+0xc=9` datatab store (overwritten by the ln_Name long that follows; ln_Type stays 0 — the datatab never writes ln_Type).
