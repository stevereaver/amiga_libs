---
type: Function
title: XpksPackerInfo
description: Returns the XpkInfo/XpkMode descriptor chain pointer.
lvo: -30
registers: -> d0 XpkInfo *
---

# ``APTR XpksPackerInfo(void)``

**LVO -30**

`lea xpkinfo(pc),a0; move.l a0,d0; rts` — hands xpkmaster a pointer
to the static XpkInfo block (see structures/XpkInfo.md).
