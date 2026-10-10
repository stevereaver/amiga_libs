---
type: Function
title: MMUType
description: Forwarded to mmu.library/GetMMUType (LVO -54).
lvo: -42
registers: -
timestamp: 2026-10-10T18:00:00Z
---

# ``char MMUType(void)``

**LVO -42** — registers `-`

Opens `mmu.library` (any version), calls its LVO -54
(`_LVOGetMMUType`), closes it again, returns the result.
Returns 0 (MUTYPE_NONE) when mmu.library cannot be opened.
