---
type: Index
title: Functions
description: LVO entries of version.library 38.36 (WB2.1).
timestamp: 2026-10-10T19:00:00Z
---

# Functions

The library has exactly four vectors — the standard skeleton only:

- [LibOpen](LibOpen.md) — LVO -6, open count and deferred-expunge bookkeeping
- [LibClose](LibClose.md) — LVO -12, close; runs a deferred expunge at zero
- [LibExpunge](LibExpunge.md) — LVO -18, unlink + free the base
- [LibNull](LibNull.md) — LVO -24, reserved vector, returns 0
