---
type: Function
title: LibExpunge
description: Library expunge vector.
---

# LibExpunge — LVO -18

If `lib_OpenCnt` is nonzero: sets `LIBF_DELEXP` in
lib_Flags (+0x0e) and returns 0.  Otherwise: pushes
seglist+base, reloads SysBase from absolute `4.w`,
exec Remove (a6@-252), FreeMem of NegSize+PosSize
(a6@-210), returns the seglist BPTR.
