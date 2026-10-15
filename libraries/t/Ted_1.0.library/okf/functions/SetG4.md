---
type: Function
title: SetG4
description: Store the a0 pointer in code-hunk global gG.
lvo: see index
registers: a0 value
timestamp: 2026-10-10T20:20:00Z
---

# ``void SetG4(APTR p)``

`movel a0,_gG; rts`.  The pointer is stored in a longword
global inside the code hunk (absolute-addressed).
