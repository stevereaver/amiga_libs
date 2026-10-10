---
type: Function
title: LibOpen
description: Standard-shaped open — bumps OpenCnt, clears private DELEXP bit.
lvo: -6
registers: a6 base -> d0 base
timestamp: 2026-10-10T23:00:00Z
---

# ``struct Library *LibOpen(void)``

**LVO -6**

`addq.w #1,lib_OpenCnt(a6); bclr #3,0x2a(a6); move.l a6,d0; rts` —
the DELEXP clear targets the private byte at base+0x2a, not
`lib_Flags` (see [Quirks](../findings/Quirks.md)).
