---
type: Function
title: LibExpunge
description: Library expunge vector.
---

# LibExpunge — LVO -18

OpenCnt nonzero -> `bset #3` of the private flag byte,
return 0.  Otherwise: SysBase from base+0x22, Remove via
jsr -252(a6), FreeMem(NegSize+PosSize) via jsr -210(a6),
returns seglist from base+0x26.