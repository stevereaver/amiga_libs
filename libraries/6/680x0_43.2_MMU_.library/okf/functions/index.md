---
type: Index
title: Functions
description: Exported functions and LVO entries analyzed for this library.
timestamp: 2026-10-10T18:00:00Z
---

# Functions

- [LibOpen](LibOpen.md) — LVO -6, openCnt++, clears LIBF_DELEXP, returns the library base.
- [LibClose](LibClose.md) — LVO -12, decrements OpenCnt when non-zero, always returns 0.
- [LibExpunge](LibExpunge.md) — LVO -18, stub: always returns 0, the library cannot be expunged.
- [LibNull](LibNull.md) — LVO -24, reserved vector, returns 0.
- [CPUType](CPUType.md) — LVO -30, returns the detected CPU model as an ASCII digit.
- [FPUType](FPUType.md) — LVO -36, returns the detected FPU model, 0 when none.
- [MMUType](MMUType.md) — LVO -42, forwarded to mmu.library/GetMMUType (LVO -54).
- [SetFPUExceptions](SetFPUExceptions.md) — LVO -48, forwarded to the CPU driver's FPUControl (LVO -222).
