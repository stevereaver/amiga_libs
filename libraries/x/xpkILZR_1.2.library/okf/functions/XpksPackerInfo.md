---
type: Function
title: XpksPackerInfo (LVO -30)
---

# XpksPackerInfo — xpkILZR 1.2

`lea 158(a6)` — returns `base+0x9e`: the XpkInfo that sits
**inside the per-library copied block** (base+0x3c + 0x62).

Consequence: a private copy's PackerInfo returns the copy's
own descriptor at `copy+0x9e` — same bytes, different
address than the master's.
