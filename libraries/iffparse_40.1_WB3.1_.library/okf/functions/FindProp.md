---
type: Function
title: FindProp
description: Searches 'prop' LCIs up the context chain (outermost-first).
lvo: -156
registers: a0,d0,d1
timestamp: 2026-10-10T18:00:00Z
---

# `struct StoredProperty *FindProp(iff,type,id)`

**LVO -156** — registers `a0,d0,d1`

Searches 'prop' LCIs up the context chain (outermost-first). Returns the StoredProperty payload or NULL.
