---
type: Finding
title: Entry returns -1
description: The hunk entry stub is `moveq #-1,d0 / rts`.
timestamp: 2026-10-10T09:40:00Z
---

# Entry returns -1

The 4-byte hunk entry at .text+0x00 returns -1 (failure for
non-resident loaders). Unlike xpkNONE_1.5 — whose `moveq #0` entry
doubled as the reserved-function vector — this build keeps a separate
`moveq #0/rts` stub at .text+0x12e for LVO -24/-42/-48/-60, and
`RT_ENDSKIP` points at module end (0x278), not the entry.
