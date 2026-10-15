---
type: Function
title: LibOpen
description: OpenCnt++, clears private flag bit, returns pb_OpenLib if set.
lvo: -6
registers: a6 = library base (in), d0 = base (out)
---

# `struct Library *LibOpen(void)`

**LVO -6**

```
addq.w #1,(32,a6)        ; lib_OpenCnt++
bclr   #3,(34,a6)        ; private flag byte @+34, bit 3
move.b #$09,(8,a6)       ; force ln_Type = NT_LIBRARY (harmless)
move.l (40,a6),d0        ; pb_OpenLib
bne.s  done
move.l a6,d0             ; fall back to self
done: rts
```
