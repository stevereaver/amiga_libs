---
type: Function
title: FPUType
description: Returns the detected FPU model, 0 when none.
lvo: -36
registers: -
timestamp: 2026-10-10T18:00:00Z
---

# ``char FPUType(void)``

**LVO -36** — registers `-`

Reads `ExecBase->AttnFlags` via the cached SysBase:
AFF_FPU40 set -> the CPU digit (integrated 040/060 FPU),
else AFF_68882 -> '2', AFF_68881 -> '1', else 0 (FPUTYPE_NONE).
