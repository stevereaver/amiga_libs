---
type: Finding
title: RebuildDeviations
description: Where the reconstruction differs from the shipped binary.
timestamp: 2026-10-15T00:00:00Z
---

# Rebuild deviations

**None — byte-identical** (`source/wbstart_h0.s` + `fixup.py`,
md5 ab05a79789225bdf074a6f808ed4ca57).  GNU ld cannot emit the
shipped HUNK_DREL32 tail itself, so `fixup.py` splices the
original's DREL32 records over the linker's RELOC32 after
asserting the (hunk, offset-set) groups agree.

The retained C model (`make cmodel`) still shows the old
deviations: code hunk 0x374 vs 0x318 (GCC codegen), while its
`.data` hunk was already byte-layout identical.  All API/tag
names in the reconstruction are reconstructed; the binary
exports none.
