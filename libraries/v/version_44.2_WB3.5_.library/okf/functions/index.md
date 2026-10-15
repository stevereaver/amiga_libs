---
type: Index
title: Functions
description: LVO entries of version.library 44.2 -- system vectors only, no public API; plus the hidden base-exported probe.
---

# Functions

version.library 44.2 has no public API: the AUTOINIT function
table contains only the four system vectors.  LVO -18 (Expunge) and
LVO -24 (ExtFunc) point to the same `LibNull` stub.

- [LibOpen](LibOpen.md) — LVO -6, OpenCnt++ and return base
- [LibClose](LibClose.md) — LVO -12, OpenCnt-- and self-free at 0
- [LibExpunge](LibExpunge.md) — LVO -18, shared null stub (does nothing)
- [LibNull](LibNull.md) — LVO -24 (ExtFunc), same stub
- [CheckSemaphore](CheckSemaphore.md) — **not an LVO**; hidden
  routine whose address LibInit stores at library-base +0x32
