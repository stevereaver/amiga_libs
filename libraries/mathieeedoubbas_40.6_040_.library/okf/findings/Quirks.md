---
type: Finding
title: Quirks
description: Oddities found in the shipped binary.
timestamp: 2026-10-10T23:10:00Z
---

# Quirks

- **Private DELEXP byte** at base+0x2a bit3 (not lib_Flags) —
  same deviation as all Berndt 40.6 builds (AMIGALIBS-22).
- **Trapping FPU code**: the "68040" library runs fintrz/fint
  which an '040 cannot execute natively — every IEEEDPFloor
  call and every IEEEDPFix conversion traps to FPSP.  Slow but
  functional; the author simply re-linked the FPU build.
- **Version-conditional gate**: pre-V39 exec passes without
  AFF_FPU40 — a 68040 system with no FPU would still load the
  library and then trap/fail inside the vectors.
- Same stack-shuffle FPU vectors, integer Cmp/Tst, and
  ExtFunc→entry aliasing as the FPU sibling.
