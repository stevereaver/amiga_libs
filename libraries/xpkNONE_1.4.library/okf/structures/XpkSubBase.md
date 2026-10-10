---
type: Structure
title: XpkSubBase
description: Private library base, 0x2a bytes (struct Library + SegList + SysBase).
resource: source/xpkbase.h
timestamp: 2026-10-10T19:45:00Z
---

# XpkSubBase

InitTable `dataSize` is 0x2a (42).

| offset | field | notes |
|-------:|-------|-------|
| 0x00   | `struct Library xsb_Lib` | standard 34 bytes |
| 0x22   | `BPTR xsb_SegList` | stored by LibInit (a0), returned by Expunge |
| 0x26   | `struct ExecBase *xsb_SysBase` | stored by LibInit (a6); used by Expunge (Remove/FreeMem) and XpksUnpackChunk (CopyMem) |

Unlike the fwfiltertype skeleton, SysBase is kept in the base rather
than read from `4.w`.
