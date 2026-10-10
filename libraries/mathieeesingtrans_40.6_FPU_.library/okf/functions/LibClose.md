---
type: Function
title: LibClose
description: Decrements OpenCnt; expunges only at 0 with the private DELEXP bit set.
lvo: -12
registers: a6 base -> d0 seglist|0
timestamp: 2026-10-10T22:30:00Z
---

# ``BPTR LibClose(void)``

**LVO -12**

```asm
moveq   #0, d0
subq.w  #1, lib_OpenCnt(a6)
bne     shared_rts            ; still open -> return 0
btst    #3, 0x2a(a6)          ; private DELEXP
beq     shared_rts            ; not pending -> return 0
        ; fall into expunge tail
```

At zero with the flag set it falls through into the same
remove+free sequence used by [LibExpunge](LibExpunge.md).
