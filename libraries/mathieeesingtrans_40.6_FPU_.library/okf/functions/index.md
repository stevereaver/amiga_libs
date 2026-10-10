---
type: Index
title: Functions
description: Exported functions and LVO entries analyzed for this library.
timestamp: 2026-10-10T22:30:00Z
---

# Functions

## System vectors

- [LibOpen](LibOpen.md) — LVO -6, opencnt++, clears private DELEXP bit.
- [LibClose](LibClose.md) — LVO -12, expunge at opcnt 0 with DELEXP set.
- [LibExpunge](LibExpunge.md) — LVO -18, mark-or-expunge.
- [ExtFunc](ExtFunc.md) — LVO -24, points at the module entry (returns 0).

## Math vectors (68881 stubs)

- [IEEESPAtan](IEEESPAtan.md) — LVO -30, fatans.
- [IEEESPSin](IEEESPSin.md) — LVO -36, fsins.
- [IEEESPCos](IEEESPCos.md) — LVO -42, fcoss.
- [IEEESPTan](IEEESPTan.md) — LVO -48, ftans.
- [IEEESPSincos](IEEESPSincos.md) — LVO -54, fsincoss (sin→d0, cos→*a0).
- [IEEESPSinh](IEEESPSinh.md) — LVO -60, fsinhs.
- [IEEESPCosh](IEEESPCosh.md) — LVO -66, fcoshs.
- [IEEESPTanh](IEEESPTanh.md) — LVO -72, ftanhs.
- [IEEESPExp](IEEESPExp.md) — LVO -78, fetoxs.
- [IEEESPLog](IEEESPLog.md) — LVO -84, flogns.
- [IEEESPPow](IEEESPPow.md) — LVO -90, exp(y·ln|x|) with sign fixup.
- [IEEESPSqrt](IEEESPSqrt.md) — LVO -96, fsqrts.
- [IEEESPTieee](IEEESPTieee.md) — LVO -102, identity rts (shared).
- [IEEESPFieee](IEEESPFieee.md) — LVO -108, identity rts (shared).
- [IEEESPAsin](IEEESPAsin.md) — LVO -114, fasins.
- [IEEESPAcos](IEEESPAcos.md) — LVO -120, facoss.
- [IEEESPLog10](IEEESPLog10.md) — LVO -126, flog10s.
