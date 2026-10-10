---
type: Index
title: Functions
description: Exported functions and LVO entries analyzed for this library.
timestamp: 2026-10-10T23:00:00Z
---

# Functions

## System vectors

- [LibOpen](LibOpen.md) — LVO -6, opencnt++, clears private DELEXP bit.
- [LibClose](LibClose.md) — LVO -12, expunge at opcnt 0 with DELEXP set.
- [LibExpunge](LibExpunge.md) — LVO -18, mark-or-expunge.
- [ExtFunc](ExtFunc.md) — LVO -24 → module entry (returns 0).

## Math vectors

- [IEEEDPFix](IEEEDPFix.md) — LVO -30, double→long via fmove.l (FPCR mode).
- [IEEEDPFlt](IEEEDPFlt.md) — LVO -36, long→double.
- [IEEEDPCmp](IEEEDPCmp.md) — LVO -42, integer 3-way compare.
- [IEEEDPTst](IEEEDPTst.md) — LVO -48, sign test (-0 counts as 0).
- [IEEEDPAbs](IEEEDPAbs.md) — LVO -54, bclr #31,d0.
- [IEEEDPNeg](IEEEDPNeg.md) — LVO -60, bchg #31,d0.
- [IEEEDPAdd](IEEEDPAdd.md) — LVO -66, faddd through the stack.
- [IEEEDPSub](IEEEDPSub.md) — LVO -72, fsubd (left - right).
- [IEEEDPMul](IEEEDPMul.md) — LVO -78, fmuld.
- [IEEEDPDiv](IEEEDPDiv.md) — LVO -84, fdivd (dividend / divisor).
- [IEEEDPFloor](IEEEDPFloor.md) — LVO -90, fintrz / fint under FPCR −inf.
- [IEEEDPCeil](IEEEDPCeil.md) — LVO -96, -floor(-x) with +0 guard.
