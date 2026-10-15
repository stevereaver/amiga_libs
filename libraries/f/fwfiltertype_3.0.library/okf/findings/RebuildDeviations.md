---
type: Finding
title: Rebuild deviations
timestamp: 2026-10-15T02:00:00Z
---

# Rebuild status

**Superseded.** As of 2026-10-15 `make` assembles `fwfiltertype.s` into
a **byte-identical** image (md5 `e6e1ad2915d73de079e659eeabf4ac58`);
`fixup.py` rewrites the RELOC32 tail to the original's descending
offset order.  The earlier gcc C build is kept as `make cmodel`.

Historical note (C model): code hunk 0x194 bytes vs original 0x1b4,
dead `cmpi.w` absent, gcc prologue differences — all moot now.
