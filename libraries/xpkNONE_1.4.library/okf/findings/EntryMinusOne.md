---
type: Finding
title: Hunk entry returns -1
timestamp: 2026-10-10T19:45:00Z
---

# Entry stub returns -1

The code hunk opens with `moveq #-1,d0 / rts` rather than the usual
`moveq #0,d0 / rts` seen in sibling libraries (fwfiltertype, version
stubs). For a resident-scanned library this entry is never executed —
the RomTag drives everything — so the -1 is cosmetic, but it's another
sign this binary wasn't built with the standard startup object.
Reproduced in `xpknone_lib.s`.
