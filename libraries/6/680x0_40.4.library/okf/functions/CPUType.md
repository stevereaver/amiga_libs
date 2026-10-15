---
type: Function
title: CPUType
description: Returns the detected CPU model as an ASCII digit.
lvo: -30
registers: -
timestamp: 2026-10-10T18:00:00Z
---

# ``char CPUType(void)``

**LVO -30** — registers `-`

Returns the byte cached at base+0x3c during LibInit: '0','1','2','3','4','6'.
Detection: highest set bit of `ExecBase->AttnFlags` (AFF_68010 ..
AFF_68040); a 68040 additionally runs a supervisor-mode probe that
executes `movec pcr,d1` (cpuprobe.s) - on the 68060 the PCR is
readable.
