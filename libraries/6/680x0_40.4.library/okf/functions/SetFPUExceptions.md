---
type: Function
title: SetFPUExceptions
description: Forwarded to the CPU driver's FPUControl (LVO -222).
lvo: -48
registers: d0,d1
timestamp: 2026-10-10T18:00:00Z
---

# ``ULONG SetFPUExceptions(ULONG flags, ULONG mask)``

**LVO -48** — registers `d0,d1`

Opens the CPU driver library ("680N0.library", minimum version
40), requires lib_Version >= 40 and lib_NegSize >= 0xde
(vector table must cover LVO -222 = `_LVOFPUControl`), calls it
with (flags d0, mask d1) and closes the driver.  Returns the old
exception mask, or 0 when no suitable driver is installed.

flag/mask bits (libraries/680x0.h): FPUCtrlB_BSUN(0), INEX(1),
DIVZ(2), UNFL(3), OVFL(4), SNAN(5), OPERR(6) - a set bit
disables the corresponding FPU exception.
