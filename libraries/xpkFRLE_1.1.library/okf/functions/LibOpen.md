---
type: Function
title: LibOpen
description: Textbook open — bumps OpenCnt, clears LIBF_DELEXP.
lvo: -6
registers: a6 base -> d0 base
timestamp: 2026-10-10T22:45:00Z
---

# ``struct Library *LibOpen(void)``

**LVO -6**

`addq.w #1,lib_OpenCnt(a6); andi.b #$f7,lib_Flags(a6); move.l a6,d0; rts`
— the textbook implementation using the real `LIBF_DELEXP` bit.
