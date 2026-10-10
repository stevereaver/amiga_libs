---
type: Function
title: LibExpunge
description: Library expunge vector.
---

# LibExpunge — LVO -18

OpenCnt nonzero -> set DELEXP bit3, return 0.  Otherwise:
`bsr`s to an empty cleanup hook (a lone `rts` — an
extension placeholder), then exec Remove (a6@-252 via
absolute SysBase 4.w) and FreeMem (a6@-210,
NegSize+PosSize), returns seglist from base+0x22.
