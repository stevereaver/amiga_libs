---
type: Function
title: XpksPackerInfo
description: Returns the static XpkInfo descriptor block.
lvo: -30
registers: a6 base -> d0 struct XpkInfo *
timestamp: 2026-10-10T22:45:00Z
---

# ``struct XpkInfo *XpksPackerInfo(void)``

**LVO -30**

`lea xpkinfo(pc),a0; move.l a0,d0; rts` — returns the 88-byte
descriptor embedded in the code hunk (see
[structures/XpkInfo](../structures/XpkInfo.md)).
