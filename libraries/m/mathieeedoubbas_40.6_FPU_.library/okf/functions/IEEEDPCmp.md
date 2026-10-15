---
type: Function
title: IEEEDPCmp
description: Three-way compare of two doubles — pure integer branch tree.
lvo: -42
registers: d0/d1 left, d2/d3 right -> d0 -1|0|+1
timestamp: 2026-10-10T23:00:00Z
---

# ``LONG IEEEDPCmp(double left, double right)``

**LVO -42**

No FPU — a sign/magnitude branch tree on the bit patterns:

- signs differ → the positive side wins, **except** both-zero
  patterns (+0 == -0, tested by `l<<1`/`r<<1` zero checks).
- both positive → signed high-word compare, then unsigned low word.
- both negative → the compare is mirrored (bit patterns reverse
  order for negatives).
- No NaN handling — NaN patterns compare by magnitude.
