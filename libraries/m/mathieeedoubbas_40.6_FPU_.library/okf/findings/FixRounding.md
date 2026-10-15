---
type: Finding
title: IEEEDPFix honours FPCR rounding mode
description: Conversion is fmove.l fp0,d0 — not guaranteed truncation.
timestamp: 2026-10-10T23:00:00Z
---

# IEEEDPFix honours FPCR rounding mode

`IEEEDPFix` (LVO -30) converts with a bare `fmove.l fp0,d0`,
which rounds per the **current FPCR**.

Update (2026-10-15): Open writes `FPCR=0x90` — double
precision + **round-toward-zero** — so a caller that went
through Open sees the classic truncating behaviour
(`IEEEDPFix(1.6) = 1`).  The vector itself remains
FPCR-dependent: under round-to-nearest (the hardware power-up
state, or a caller that reprogrammed FPCR) it returns
`IEEEDPFix(1.6) = 2`.

The Kickstart `mathieeedoubbas` convention for this vector is
unconditional truncation toward zero (`fintrz`-equivalent;
the 10.881 builds use `fintrz`), so this build is a real
behavioural deviation vs the Commodore library: a caller that
sets FPCR to round-to-nearest (or calls the vector without
Open, e.g. after the ROM's own init) gets rounding, not
truncation.
