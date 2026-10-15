---
type: Function
title: ModuleEntry
description: Reserved vector encoded as a negative offset to the module entry.
lvo: -24
registers: -
timestamp: 2026-10-10T19:30:00Z
---

# ``void ModuleEntry(void)``

**LVO -24**

Word-offset table entry `0xffd2` (-46): points backwards to offset
0, the `moveq #0,d0 / rts` loader entry.  Reserved vector that
returns 0.
