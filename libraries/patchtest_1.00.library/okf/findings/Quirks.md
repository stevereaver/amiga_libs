---
type: Finding
title: patchtest quirks
---

# Quirks

1. **OpenLibrary result unchecked.**  The per-open init does
   `OpenLibrary("intuition.library",0)` into data+0x14 and
   returns 0 unconditionally -- the library "opens" fine even
   when intuition is unavailable.  Calling PTBeep then jumps
   through NULL+(-96) -> crash.  Reproduced (no NULL guard in
   the reconstruction).

2. **Version is incidentally 0.**  The OpenLibrary version arg
   comes from whatever d0 held at the call site -- in this
   build it happens to be 0 (any version).  Reconstruction
   passes 0 explicitly.

3. **Cross-hunk RomTag.**  name/idstr point into hunk2 (the
   functab/strings hunk) and init into hunk1 (the InitTable
   data hunk) -- the resident scan crosses hunks, which is
   legal but unusual.  Reconstruction uses a conventional
   single-hunk layout.

4. **-24 reserved slot = entry stub.**  The functab's reserved
   entry relocates to hunk0+0 (`moveq #0,d0 / rts`), not a
   dedicated null function -- the entry stub doubles as the
   reserved-vector stub.

5. **Author name.**  idstr credits "Hans B|hler" (the binary
   byte renders as `|`/`ö` depending on charset).
