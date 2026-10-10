---
type: Function
title: ExtFunc
description: Reserved vector — shares the null stub.
lvo: -24
registers: -> d0 0
timestamp: 2026-10-10T22:45:00Z
---

# ExtFunc

**LVO -24**

Points at the shared `moveq #0,d0; rts` stub (hunk +0x1b8) — not
the module entry, which returns -1 here.  Also used for the three
unimplemented sublib slots.
