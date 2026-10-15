---
type: Function
title: IEEEDPTst
description: Sign of a double — add.l d0,d0 shifts sign to carry.
lvo: -48
registers: d0/d1 -> d0 -1|0|+1
timestamp: 2026-10-10T23:00:00Z
---

# ``LONG IEEEDPTst(double x)``

**LVO -48**

`add.l d0,d0` puts the sign into carry and the rest-of-high word
into Z-flag terms: carry set → negative (return -1 unless zero);
nonzero → +1; all-zero → 0.  `-0` correctly reports 0.
