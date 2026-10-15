---
type: Index
title: Findings
description: Quirks, open questions, and version differences for this library.
---

# Findings

- [DeadInitByte](DeadInitByte.md) — InitStruct dead-store: ln_Type never set, degenerate OpenLibrary check
- [EndSkipMid](EndSkipMid.md) — RT_ENDSKIP points at the InitTable, not the hunk end
- [CloseA5Bug](CloseA5Bug.md) — LibClose tests the flag via an uninitialised a5
- [ExpungeRegQuirk](ExpungeRegQuirk.md) — movem save/restore mismatch clobbers caller's d2
- [NonStandardRegs](NonStandardRegs.md) — public functions return in d3/d2, not d0
