---
type: Finding
title: Rebuild deviations (historical)
description: >-
  Deviations of the earlier C reconstruction.  SUPERSEDED:
  source/version.s + fixup.py now rebuilds the file byte-identically
  (md5 09de0ebaf04f04a4b7f27b84a18a2db4).
timestamp: 2026-10-15T00:00:00Z
---

# Rebuild deviations (C model — superseded)

The canonical build is `source/version.s` + `source/fixup.py`,
byte-identical to the shipped binary including the empty second CODE
hunk record and descending RELOC32 order.  The notes below applied to
the earlier C reconstruction (`make cmodel`): GCC wraps vectors in a6
save/restore (longer code), and stock ld cannot emit the empty second
hunk.  All table regions were already byte-identical.
- **Revision mismatch**: idstr "versionlib 34.1" but datatab writes lib_Revision=28.
