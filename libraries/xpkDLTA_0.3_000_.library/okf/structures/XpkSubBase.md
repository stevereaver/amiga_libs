---
type: Structure
title: XpkSubBase
description: Private library base, 0x26 bytes (struct Library + SegList only).
---

# XpkSubBase

InitTable `dataSize` is 0x26 (38) — identical layout to xpkNONE 1.5.

| offset | field | notes |
|-------:|-------|-------|
| 0x00   | `struct Library` | standard 34 bytes |
| 0x22   | `BPTR SegList`   | stored by LibInit (a0), returned by Expunge |

No SysBase field: Expunge reads ExecBase from absolute `4.W`.
Unlike 0.2, no descriptors live in the base.
