---
type: Index
title: Functions
description: System vectors of the Lynxx 68040.library 46.9 loader.
---

# Functions

Only the four mandatory system vectors exist; Close, Expunge and
ExtFunc share one `moveq #0,d0/rts` stub. No user LVOs.

- [LibInit](LibInit.md) — AUTOINIT init routine (not an LVO)
- [LibOpen](LibOpen.md) — LVO -6, returns forwarded library base
- [LibClose](LibClose.md) — LVO -12/-18/-24 shared null stub
