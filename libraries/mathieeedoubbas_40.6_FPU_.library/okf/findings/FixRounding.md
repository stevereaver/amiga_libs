---
type: Finding
title: IEEEDPFix honours FPCR rounding mode
description: Conversion is fmove.l fp0,d0 — not guaranteed truncation.
timestamp: 2026-10-10T23:00:00Z
---

# IEEEDPFix honours FPCR rounding mode

`IEEEDPFix` (LVO -30) converts with a bare `fmove.l fp0,d0`,
which rounds per the **current FPCR** — default round-to-nearest
gives `IEEEDPFix(1.6) = 2` and `IEEEDPFix(-1.6) = -2`.

The Kickstart `mathieeedoubbas` convention for this vector is
truncation toward zero (`fintrz`-equivalent; the 10.881 builds
use `fintrz`), so this build returns different results for
non-integers under the default FPCR.  Code that sets FPCR to
round-toward-zero gets the classic behaviour — arguably the
author intended callers to control it, but it is a real
behavioural deviation vs the Commodore library.
