---
type: Structure
title: DSP3210Base
description: Private library base, 0x2a bytes (struct Library + SegList + spare).
resource: source/dspbase.h
timestamp: 2026-10-10T20:10:00Z
---

# DSP3210Base

`MakeLibrary` dataSize 0x2a (42).

| offset | field | notes |
|-------:|-------|-------|
| 0x00   | `struct Library db_Lib` | standard 34 bytes |
| 0x22   | `BPTR db_SegList` | stored by InitBase, returned by Expunge |
| 0x26   | `ULONG db_Unused26` | allocated, never touched |

No SysBase field — Expunge and DSPRelocate read `4.w` (ABSEXECBASE).
