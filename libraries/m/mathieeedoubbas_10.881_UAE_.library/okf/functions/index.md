---
type: Index
title: Functions
description: Exported functions and LVO entries analyzed for this library.
---

# Functions

AUTOINIT word-offset table; offsets relative to table start at text+0x30.

- [LibOpen](LibOpen.md) — LVO -6, `a6 = lib base -> d0 = base`
- [LibClose](LibClose.md) — LVO -12, `a6 = lib base -> d0 = seglist/0`
- [LibExpunge](LibExpunge.md) — LVO -18, `a6 = lib base -> d0 = seglist/0`
- [LibNull](LibNull.md) — LVO -24, `(reserved/ExtFunc) -> d0 = 0`
- [IEEEDPFix](IEEEDPFix.md) — LVO -30, `long IEEEDPFix(d0/d1 parm)`
- [IEEEDPFlt](IEEEDPFlt.md) — LVO -36, `double IEEEDPFlt(d0 integer)`
- [IEEEDPCmp](IEEEDPCmp.md) — LVO -42, `long IEEEDPCmp(d0/d1 left, d2/d3 right)`
- [IEEEDPTst](IEEEDPTst.md) — LVO -48, `long IEEEDPTst(d0/d1 parm)`
- [IEEEDPAbs](IEEEDPAbs.md) — LVO -54, `double IEEEDPAbs(d0/d1 parm)`
- [IEEEDPNeg](IEEEDPNeg.md) — LVO -60, `double IEEEDPNeg(d0/d1 parm)`
- [IEEEDPAdd](IEEEDPAdd.md) — LVO -66, `double IEEEDPAdd(d0/d1 left, d2/d3 right)`
- [IEEEDPSub](IEEEDPSub.md) — LVO -72, `double IEEEDPSub(d0/d1 left, d2/d3 right)`
- [IEEEDPMul](IEEEDPMul.md) — LVO -78, `double IEEEDPMul(d0/d1 f1, d2/d3 f2)`
- [IEEEDPDiv](IEEEDPDiv.md) — LVO -84, `double IEEEDPDiv(d0/d1 dividend, d2/d3 divisor)`
- [IEEEDPFloor](IEEEDPFloor.md) — LVO -90, `double IEEEDPFloor(d0/d1 parm)`
- [IEEEDPCeil](IEEEDPCeil.md) — LVO -96, `double IEEEDPCeil(d0/d1 parm)`
