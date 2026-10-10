---
type: Index
title: Functions
description: Exported functions and LVO entries analyzed for this library.
timestamp: 2026-10-10T21:10:00Z
---

# Functions

- [LibOpen](LibOpen.md) — LVO -6, clears DELEXP, bumps lib_OpenCnt.
- [LibClose](LibClose.md) — LVO -12, decrement; expunge at 0 with DELEXP.
- [LibExpunge](LibExpunge.md) — LVO -18, closes support libs, frees base.
- [Reserved](Reserved.md) — LVOs -24 and -30 share a `clr.l d0/rts` stub.
- [WBStart](WBStart.md) — LVO -36, tag-driven OpenWorkbenchObjectA wrapper
  with self-contained path/search-path resolution.
