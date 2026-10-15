---
type: Finding
title: Rebuild deviations (historical)
description: >-
  Deviations of the earlier C reconstruction.  SUPERSEDED:
  source/version.s + fixup.py now rebuilds the file byte-identically
  (md5 683beb93ebc5851dfa79a1f107024c43).
timestamp: 2026-10-15T00:00:00Z
---

# Rebuild deviations (C model — superseded)

The canonical build is `source/version.s` + `source/fixup.py`,
byte-identical to the shipped binary including the empty second CODE
hunk record and descending RELOC32 order.  The notes below applied to
the earlier C reconstruction (`make cmodel`): GCC wraps vectors in a6
save/restore (longer code), and stock ld cannot emit the empty second
hunk.  All table regions were already byte-identical.
- **Revision mismatch**: idstr "mylib 33.1" but datatab writes lib_Revision=56 (0x38).
