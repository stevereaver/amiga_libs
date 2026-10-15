---
type: Finding
title: FPCR write in Open
description: Open unconditionally programs the 68881 control register to 0x10.
---

# FPCR write in Open

The shipped Open does:

```
moveq   #0x10,d0         ; 7010
fmove.l d0,fpcr          ; f200 9000  -- unconditional, no read-back
```

(Contrast mathieeesingbas 10.881, whose Open does the conditional
`fmove.l fpcr,d0` / range-check / `fmove.l #0x80,fpcr` sequence.)

## What 0x10 means

FPCR low byte = MODE control: bits 7:6 = rounding precision
(00 ext, 01 single, 10 double, 11 undef), bits 5:4 = rounding mode
(00 nearest, 01 zero, 10 -inf, 11 +inf).

- `0x10` = precision **extended**, mode **round-toward-zero**.

Net effect: every Open forces extended-precision arithmetic with
truncating rounding.  That is exactly what makes `IEEEDPFix` behave like
a C `(long)` cast -- `fmove.l fp0,d0` honours the FPCR rounding mode, so
with RZ `fix(-42.9)` = -42, `fix(1.5)` = 1 (vs -43/2 under
round-nearest).  Verified by the oracle with `fpcr=0x10` vs `fpcr=0`.
Being unconditional, Open also silently discards any FPCR mode the
caller had selected (there is no SetFPCR-style API in this library).
