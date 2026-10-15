---
type: Finding
title: Apollo/AC68080 handling in 47.2
description: PCR signature check, 'A' CPU type, dead apollo.library string.
timestamp: 2026-10-10T18:00:00Z
---

# Apollo handling in 47.2

The 47.2 probe additionally reads the 68060 PCR and compares its
high word (masked with 0xfffe) against 0x0430.  Outcomes:

- probe trapped (no PCR) -> CPUType '4' (68040)
- PCR == 0x043x           -> CPUType '6' (genuine 68060)
- PCR readable, != 0x043x -> CPUType 'A' (65, Apollo AC68080 core)

`OpenCPUDriver` refuses cpu chars > '9' (`cmpib #'9'; bhi`), so on
an Apollo core no driver is opened and LibInit expunges the
library - consistent with this release shipping no Apollo driver.

An `"apollo.library"` string sits in the data hunk between
"680x0.library" and "mmu.library" but **no code references it**
(dead data - presumably leftover from a planned driver lookup).
It is reproduced in `source/680x0_lib.s`.

CPUType 'A' is undocumented: Mu680x0Libs `libraries/680x0.h` only
defines CPUTYPE_68000..68060 ('0'..'6').
