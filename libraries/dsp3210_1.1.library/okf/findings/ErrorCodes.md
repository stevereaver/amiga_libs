---
type: Finding
title: Even error numbering (pre-v7)
timestamp: 2026-10-10T20:10:00Z
---

# Even error numbers

This build returns round negative errors: -1 (bad blob), -2 (unknown
section), -3 (no memory), -10 (unknown reloc), -20 (bad sym section),
-21 (unresolved external), -30 (short-reloc overflow).

The v7 `libraries/dsp3210.h` uses an all-odd scheme (-1,-3,-5,-7,-9,
-11,-21,-23,-31) and documents why: *"Only odd negative numbers are
errors. DSPLoadMod might return an even negative if there is memory
beyond 0x80000000"* — the renumbering was a deliberate fix so error
detection could test bit 0. Only -21 (bad symbol section) kept its
value between schemes.
