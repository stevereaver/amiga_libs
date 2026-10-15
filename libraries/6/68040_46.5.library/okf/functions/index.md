---
type: Index
title: Functions
description: System vectors of the Phase5 68040.library 46.5 loader.
---

# Functions

Only the four mandatory system vectors exist; Close, Expunge and
ExtFunc are independent null stubs (all `moveq #0,d0/rts`).
No user LVOs.

- [LibInit](LibInit.md) — AUTOINIT init routine (not an LVO)
- [LibOpen](LibOpen.md) — LVO -6, returns pb_OpenLib if set
- [LibClose](LibClose.md) — LVO -12, null stub (never decrements)
- [LibExpunge](LibExpunge.md) — LVO -18/-24 null stubs
