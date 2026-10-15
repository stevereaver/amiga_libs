---
type: Structure
title: XpkSubBase
description: Private library base, 0x26 bytes (struct Library + SegList only).
resource: source/xpkNONE.c
timestamp: 2026-10-10T09:20:00Z
---

# XpkSubBase

InitTable `dataSize` is 0x26 (38) — one field smaller than the 1.4
skeleton.

| offset | field | notes |
|-------:|-------|-------|
| 0x00   | `struct Library xsb_Lib` | standard 34 bytes |
| 0x22   | `BPTR xsb_SegList` | stored by LibInit (a0), returned by Expunge |

No `xsb_SysBase`: this build reads ExecBase from absolute `4.W`
inside LibExpunge and XpksUnpackChunk instead of stashing it in the
base (see [SysBaseAt4](../findings/SysBaseAt4.md)).
