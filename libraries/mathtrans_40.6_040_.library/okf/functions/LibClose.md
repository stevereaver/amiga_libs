---
type: Function
title: LibClose
description: Library close vector at LVO -12.
---

# LibClose — LVO -12

Decrements `lib_OpenCnt`; when it reaches zero and the
private DELEXP bit is set, expunges (exec Remove at
a6@-252, then FreeMem at a6@-210 of NegSize+PosSize).
Returns the seglist BPTR on expunge, else 0.
