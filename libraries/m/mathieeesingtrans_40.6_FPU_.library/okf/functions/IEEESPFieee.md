---
type: Function
title: IEEESPFieee
description: IEEE→FFP conversion — a bare rts in this IEEE-native build.
lvo: -108
registers: d0 -> d0 (unchanged)
timestamp: 2026-10-10T22:30:00Z
---

# ``float IEEESPFieee(float x)``

**LVO -108**

Same vector address as [IEEESPTieee](IEEESPTieee.md) — a bare
`rts` returning d0 unchanged.  Callers expecting a real FFP
result get the IEEE input back; harmless for this build since
its consumers work in IEEE anyway.
