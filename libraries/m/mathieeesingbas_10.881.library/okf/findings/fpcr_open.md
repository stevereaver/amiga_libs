---
type: Finding
title: FPCR write in Open
description: Open conditionally programs the 68881 control register to 0x80.
---

# FPCR write in Open

The shipped Open does:

```
fmove.l fpcr,d0        ; f200 b000 -- transfers FPCR into d0 AND updates CCR
beq   write            ; fpcr == 0          -> write
cmpi.w #0x40,d0
bcs   keep             ; fpcr < 0x40        -> keep
cmpi.w #0x80,d0
bcc   keep             ; fpcr >= 0x80       -> keep
write: fmove.l #0x80,fpcr   ; f23c 9000 0000 0080
keep:  addq.w #1,0x20(a6) ; OpenCnt++
```

So FPCR is rewritten to `0x80` iff `fpcr == 0` or `0x40 <= fpcr < 0x80`.

## CCR semantics (corrected)

An earlier note claimed `fmove.l fpcr,d0` leaves the integer CCR
untouched, making the `beq` test leftover flags.  That is wrong for the
MC68020+68881: an FPU transfer *into an integer data register* is
evaluated by the main processor, which sets N/Z (and clears V/C) in the
CCR.  The `beq` therefore genuinely tests `fpcr == 0` on real hardware.
The oracle models exactly this.

## What 0x80 means

FPCR low byte = MODE control: bits 7:6 = rounding precision
(00 ext, 01 single, 10 double, 11 undef), bits 5:4 = rounding mode
(00 nearest, 01 zero, 10 -inf, 11 +inf).

- `0x80` = precision **double**, mode **to-nearest**.
- Range `[0x40,0x80)` = precision *single* (any rounding mode).
- Range `>= 0x80` = precision double or undefined; range `< 0x40` minus
  zero = precision extended.

Net effect: Open upgrades the FPU from power-on (`0`) or
single-precision mode to double-precision + round-nearest; explicit
extended/double/undefined modes are preserved.  Note the `cmpi.w`
checks only test the low word — FPCR's high word is always 0 on a
68881 anyway.
