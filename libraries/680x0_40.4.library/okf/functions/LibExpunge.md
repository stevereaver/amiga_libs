---
type: Function
title: LibExpunge
description: Stub: always returns 0, the library cannot be expunged.
lvo: -18
registers: -
timestamp: 2026-10-10T18:00:00Z
---

# ``LONG LibExpunge(void)``

**LVO -18** — registers `-`

Just `moveq #0,d0 / rts`.  Once resident, 680x0.library stays
in memory (it is a system driver loader).  The only code that
frees the base is the init failure path.
