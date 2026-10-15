---
type: Structure
title: XpkSubBase
description: Private library base, 0xfc bytes — descriptors embedded.
---

# XpkSubBase

InitTable `dataSize` is 0xfc (252): the biggest member is the pair of
embedded XPK descriptors, both populated by the InitStruct table.

| offset | field | notes |
|-------:|-------|-------|
| 0x00   | `struct Library`  | standard 34 bytes |
| 0x22   | `BPTR SegList`    | stored by LibInit (a0), returned by Expunge |
| 0x26   | `XpkInfo` (88)    | built by InitStruct; returned by XpksPackerInfo (`lea a6@(0x26)`) |
| 0x62   | — inside XpkInfo: `xi_ModeDesc` | linked by LibInit to base+0x7e |
| 0x7e   | `XpkMode` (42)    | built by InitStruct ("ByteMode") |
| 0xa8-0xfb | unused       | zero |

No SysBase field: Expunge reads ExecBase from absolute `4.W`.
