---
type: Finding
title: RT_ENDSKIP points mid-module
description: EndSkip = RT_INIT (0x52, the InitTable) instead of the end of the code hunk.
timestamp: 2026-10-10T18:00:00Z
---

# RT_ENDSKIP points mid-module

The RomTag's EndSkip is 0x52 — the InitTable address, the same as
RT_INIT.  Nominal Amiga convention puts EndSkip at the end of the
resident area.  fwfiltertype shows the same pattern with its init
routine address.  Practical impact: exec's resident scan would
consider the module to end at 0x52; since it is AUTOINIT and loaded
as a single hunk this is harmless, but it means the strings/table
region is nominally "outside" the module.  Reproduced faithfully
(`RT_ENDSKIP = _inittab`).
