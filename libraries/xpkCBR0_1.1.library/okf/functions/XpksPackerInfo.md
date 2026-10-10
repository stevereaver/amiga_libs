---
type: Function
title: XpksPackerInfo
description: Returns the XpkInfo descriptor.
---

# XpksPackerInfo — LVO -30

`lea a6@(0x28),a0 / movel a0,d0 / rts` — returns a
pointer to the XpkInfo descriptor embedded in the
library base at +0x28 (filled by LibInit; see
structures/XpkInfo.md).
