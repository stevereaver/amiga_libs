---
type: Function
title: OpenIFF
description: IFFF_READ: seeks to start / reads FORM id+type into root context, validates IFF.
lvo: -36
registers: a0,d0
timestamp: 2026-10-10T18:00:00Z
---

# `LONG OpenIFF(iff,rwMode)`

**LVO -36** — registers `a0,d0`

IFFF_READ: seeks to start / reads FORM id+type into root context, validates IFF. IFFF_WRITE: initialises write state. Errors -> IFFERR_*.
