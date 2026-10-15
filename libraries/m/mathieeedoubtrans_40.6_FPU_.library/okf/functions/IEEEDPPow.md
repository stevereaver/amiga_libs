---
type: Function
title: IEEEDPPow
description: x^y via e^(y*log x) with negative-x sign logic.
---

# IEEEDPPow — LVO -90

    tstl   d0; bpl  core          | x >= 0 -> direct
    bclr   #31,d0                 | |x|
    moveml d2-d3,-(sp)            | save y
    fintd  sp@,fp0; fsubd sp@,fp0 | trunc(y) - y
    fbne   -> return (0.0)        | non-integer y, x<0 -> 0
    bsrs   core                   | pow(|x|,y) -> d0:d1
    fmoved sp@+,fp0               | recover y (drops saves)
    fmodd  #2.0,fp0               | y mod 2
    fbeq   -> rts                 | even y
    bset   #31,d0                 | odd y -> re-negate

pow core (shared): push d0-d3 (x,y); save FPCR -> clrb ->
round-to-nearest; `flognd sp@+` log(x); `fmuld sp@` *y;
`fetoxx fp0` e^(y log x); store over the y slot; restore
FPCR; pop result.  The `fmoved sp@+` after the bsr is the
elegant part -- it reads saved y AND frees the stack in one
instruction.

x<0 with non-integer y returns +0.0 rather than NaN --
shipped semantic preserved.