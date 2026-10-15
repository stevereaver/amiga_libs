---
type: Function
title: LibNull
description: Null vectors.
---

# LibNull — LVO -24 (ExtFunc), -42, -48, -60

All four slots are NEGATIVE functab offsets back to hunk+0 --
the module entry stub `moveq #0,d0/rts` doubles as the null
vector (returns 0, not the -1 of V1.1).
