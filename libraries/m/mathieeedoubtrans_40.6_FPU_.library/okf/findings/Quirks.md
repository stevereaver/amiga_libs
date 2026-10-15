---
type: Finding
title: Quirks
description: Defects and oddities of the shipped binary.
---

# Quirks

1. **Private DELEXP byte.**  Deferred expunge uses bit3 of
   base+0x2a, NOT lib_Flags bit3 -- so Exec's own expunge
   request tracking (which inspects lib_Flags) is bypassed;
   only these library vectors honour the flag.  Martin
   Berndt framework signature.

2. **Init gate: btst pair, not a mask.**  `btst #1` (68020)
   then `btst #4` (68881) -- rejects 68882-only systems even
   though the idstring says "68881/82" (a 68882 sets bit5,
   not bit4, on OS versions that distinguish them).

3. **RT_ENDSKIP points at the InitTable**, not at the end of
   the module -- the resident-scan "skip" lands on
   data/InitStruct rather than the hunk end.  Same quirk as
   every Martin Berndt build in this repo.

4. **Pow(-x, non-integer y) returns +0.0**, not NaN -- the
   shipped semantic is a flat zero (C99 would give NaN).

5. **fmoved sp@+ as a dual-purpose pop+load** in Pow: after
   `bsr _pow_core`, the saved d2/d3 (=y) is popped straight
   into fp0 for the `fmodd #2` odd/even test -- one
   instruction both restores the stack and recovers y.

6. **Pow forces FPCR to round-to-nearest** (clrb on the
   saved FPCR) for the log/exp evaluation, restoring it on
   exit -- a silent mode fix-up callers can't see.

7. **Module entry returns 0** (not -1): the same stub backs
   ExtFunc.