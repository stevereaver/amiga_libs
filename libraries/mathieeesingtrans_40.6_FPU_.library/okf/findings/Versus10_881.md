---
type: Finding
title: 40.6 vs. the 10.881 line
description: Differences between this FPU build and Kickstart 1.x 10.881.
timestamp: 2026-10-10T22:30:00Z
---

# 40.6 vs. 10.881

| aspect | 10.881 (KS1.x) | 40.6 (Berndt) |
|---|---|---|
| module entry | bare `rts` | `moveq #0,d0; rts` |
| RomTag version | 45 | 40 |
| idstring | `MST 10.881` | `mathieeesingtrans 40.6 (7.4.95) for 68881/82\r\n(c) 1995 by Martin Berndt` |
| base size | 0x3c | 0x2c |
| no-FPU path | opens `Libs:NoFPU/mathieeesingtrans.library` | none — init fails |
| FPU check | AFF_68881 | AFF_68020 && AFF_68881 |
| DELEXP flag | lib_Flags (inits with 0x06 flags) | private byte +0x2a |
| functab | word offsets | absolute longwords |
| Tieee/Fieee | real FFP↔IEEE converters | shared bare `rts` |
| Open side effect | forces FPCR 0x80 (conditional) | none |
| Pow | more elaborate (edge cases) | exp(y·ln|x|) + parity fix |

The API surface is identical (same fd order); internals are a
minimal rewrite for 68881/82-equipped machines.
