---
type: Index
title: Findings
description: Quirks and deviations in this build.
timestamp: 2026-10-10T23:10:00Z
---

# Findings

- [VersusFPU](VersusFPU.md) — the "68040" build ships the
  identical 68881 code; only the init gate differs.
- [FixRounding](FixRounding.md) — IEEEDPFix rounds per FPCR,
  not guaranteed truncation (same as FPU build).
- [Quirks](Quirks.md) — private DELEXP byte, stack-shuffle
  vectors, integer Cmp/Tst.
