---
type: Function
title: LibOpen
description: Standard-shaped open — bumps OpenCnt, clears the private DELEXP bit.
lvo: -6
registers: a6 base -> d0 base
timestamp: 2026-10-10T22:30:00Z
---

# ``struct Library *LibOpen(void)``

**LVO -6**

```asm
addq.w  #1, lib_OpenCnt(a6)
bclr    #3, 0x2a(a6)          ; private flag byte, not lib_Flags
move.l  a6, d0
rts
```

The DELEXP clear targets **base+0x2a bit3**, a private flag —
lib_Flags is never touched (see [Quirks](../findings/Quirks.md)).
