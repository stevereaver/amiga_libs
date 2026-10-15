---
type: Function
title: LibExpunge
description: Library expunge vector at LVO -18.
---

# LibExpunge — LVO -18

If `lib_OpenCnt` is nonzero: sets the private DELEXP bit
(bit3 of base+0x2a) and returns 0.  Otherwise removes the
library node (exec Remove a6@-252) and frees
NegSize+PosSize bytes (exec FreeMem a6@-210), returning
the saved seglist BPTR.
