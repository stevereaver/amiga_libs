---
type: Function
title: IEEEDPSincos
description: sin to d0:d1, cos to *a0.
---

# IEEEDPSincos — LVO -54

    moveml d0-d1,-(sp)
    fsincosd sp@,fp1:fp0    | FPc:FPs = fp1:fp0 -> fp1=cos, fp0=sin
    fmoved fp0,sp@          | sin on stack
    pop d0/d1               | sin in d0:d1
    fmoved fp1,a0@          | cos -> *cosptr (a0)

So the ABI is the documented one: sin in d0:d1, cos stored
through a0.  (fsincos loads COS into the FIRST listed reg,
SIN into the second -- easy to misread.)