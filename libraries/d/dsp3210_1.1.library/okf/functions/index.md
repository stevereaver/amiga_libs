---
type: Index
title: Functions
description: All 6 LVO entries (-6 .. -36), names per dsp3210_lib.fd.
---

# Functions

System vectors:

- [LibOpen](LibOpen.md) — LVO -6
- [LibClose](LibClose.md) — LVO -12 (over-close safe, unusual)
- [LibExpunge](LibExpunge.md) — LVO -18
- [LibNull](LibNull.md) — LVO -24 (reserved)

User functions:

- [DSPCalcLen](DSPCalcLen.md) — LVO -30, relocation size calculator
- [DSPRelocate](DSPRelocate.md) — LVO -36, d32 blob loader/relocator

Init path (not LVOs):

- [ResidentInit](ResidentInit.md) — rt_Init bootstrap (MakeLibrary+AddLibrary)
- [InitBase](InitBase.md) — libInit hook for MakeLibrary
