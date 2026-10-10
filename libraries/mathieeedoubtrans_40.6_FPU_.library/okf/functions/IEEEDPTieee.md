---
type: Function
title: IEEEDPTieee
description: IEEE double -> IEEE single.
---

# IEEEDPTieee — LVO -102

`moveml d0-d1,-(sp); fmoved sp@+,fp0; fmoves fp0,d0; rts` --
pushes the double just to reload it into fp0 and demote to
single.  IEEEDPTieee(d0:d1 double) -> d0 single.