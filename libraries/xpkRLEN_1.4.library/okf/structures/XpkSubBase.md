---
type: Structure
title: XpkSubBase
description: Private library base, 0x2a bytes — the extra long is never used.
resource: source/xpkRLEN.c
timestamp: 2026-10-10T09:40:00Z
---

# XpkSubBase

InitTable `dataSize` is 0x2a (42).

| offset | field | notes |
|-------:|-------|-------|
| 0x00   | `struct Library xsb_Lib` | standard 34 bytes |
| 0x22   | `BPTR xsb_SegList` | stored by LibInit (a0), returned by Expunge |
| 0x26   | `ULONG xsb_Unused` | reserved by dataSize, never read or written |

The 0x26 slot looks like the `xsb_SysBase`/`info pointer` field of the
generic xpk sublib skeleton (cf. xpkNONE_1.4), but this build reads
ExecBase from `4.W` and LibInit only stores the seglist — the field
stays zero forever.
