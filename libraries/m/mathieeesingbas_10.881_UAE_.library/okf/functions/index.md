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
- [IEEESPFix](IEEESPFix.md) — LVO -30, `long IEEESPFix(d0 parm)`
- [IEEESPFlt](IEEESPFlt.md) — LVO -36, `float IEEESPFlt(d0 integer)`
- [IEEESPCmp](IEEESPCmp.md) — LVO -42, `long IEEESPCmp(d0 left, d1 right)`
- [IEEESPTst](IEEESPTst.md) — LVO -48, `long IEEESPTst(d0 parm)`
- [IEEESPAbs](IEEESPAbs.md) — LVO -54, `float IEEESPAbs(d0 parm)`
- [IEEESPNeg](IEEESPNeg.md) — LVO -60, `float IEEESPNeg(d0 parm)`
- [IEEESPAdd](IEEESPAdd.md) — LVO -66, `float IEEESPAdd(d0 left, d1 right)`
- [IEEESPSub](IEEESPSub.md) — LVO -72, `float IEEESPSub(d0 left, d1 right)`
- [IEEESPMul](IEEESPMul.md) — LVO -78, `float IEEESPMul(d0 f1, d1 f2)`
- [IEEESPDiv](IEEESPDiv.md) — LVO -84, `float IEEESPDiv(d0 dividend, d1 divisor)`
- [IEEESPFloor](IEEESPFloor.md) — LVO -90, `float IEEESPFloor(d0 parm)`
- [IEEESPCeil](IEEESPCeil.md) — LVO -96, `float IEEESPCeil(d0 parm)`
