---
type: Function
title: LibClose
description: Decrements OpenCnt; expunges at 0 with private DELEXP set.
lvo: -12
registers: a6 base -> d0 seglist|0
timestamp: 2026-10-10T23:00:00Z
---

# ``BPTR LibClose(void)``

**LVO -12**

`moveq #0,d0; subq.w #1,lib_OpenCnt(a6); bne rts; btst #3,0x2a(a6);
beq rts` — falls into the shared remove+free tail of
[LibExpunge](LibExpunge.md) only when marked.
