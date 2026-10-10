---
type: Function
title: LibExpunge
description: LVO -18 -- expunge or defer.
---

# LibExpunge — LVO -18

If `lib_OpenCnt` is nonzero, sets the private DELEXP bit
(base+0x2a bit3) and returns 0.  Otherwise `Remove()`s the
library node (jsr -252(exec)) and `FreeMem()`s
`base - NegSize` of `NegSize+PosSize` bytes (jsr -210(exec)),
returning the seglist in d0.
