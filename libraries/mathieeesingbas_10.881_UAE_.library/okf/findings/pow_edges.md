---
type: Finding
title: Edge-case encoding notes
description: Conversion / shared-tail edge cases in mathieeesingbas.library.
---

# Edge cases

- There is NO Pow in this library (that is mathieeesingtrans); an
  earlier draft of this note imported trans-library detail.  The
  reserved LVO -24 body `moveq #0,d0; rts` doubles as the common
  "return 0" tail for Close and the deferred-Expunge path.
- IEEESPCmp quirk: when d1 < 0 and d0 == +0, it first `bset #31,d0`
  turning +0 into the bit pattern 0x80000000 so the following unsigned
  `sub.l d1,d0` compare orders -0/-small values correctly.
- IEEESPTst distinguishes -0.0 (0x80000000 -> 0) from negatives via the
  `add.l d0,d0` carry + zero check.
- IEEESPFloor/Ceil on NaN take the unordered FBcc branch and return the
  NaN unchanged (verified by oracle: 0x7fc00001 in -> 0x7fc00001 out).
