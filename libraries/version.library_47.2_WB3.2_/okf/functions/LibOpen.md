---
type: Function
title: LibOpen
description: Textbook open — bumps lib_OpenCnt, clears LIBF_DELEXP.
lvo: -6
registers: a6 base -> d0 base
timestamp: 2026-10-10T21:55:00Z
---

# ``struct Library *LibOpen(void)``

**LVO -6**

```asm
addq.w  #1, lib_OpenCnt(a6)
bclr    #3, lib_Flags(a6)      ; LIBF_DELEXP
move.l  a6, d0
rts
```

Standard open semantics — unlike the 39/40.x builds this one
*does* clear `LIBF_DELEXP` on open.
