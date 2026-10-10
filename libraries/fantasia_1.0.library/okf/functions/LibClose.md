---
type: Function
title: LibClose
description: OpenCnt--; expunges if flag bit set — but tests it through the caller's a5.
lvo: -12
registers: a6 = library base, a5 = caller's a5 (bug)
timestamp: 2026-10-10T18:00:00Z
---

# `ULONG LibClose(void)`

**LVO -12** — registers `a6 = libbase`

`clr.l d0; subq.w #1,32(a6); bne rts; btst #3,46(a5); beq rts;
bsr Expunge; rts`

Bug: a5 is never loaded in this function, so the deferred-expunge
test `btst #3,46(a5)` reads byte 0x2e of *whatever the caller left
in a5*.  Only when that location happens to have bit 3 set does a
zeroed OpenCnt actually expunge.  Reproduced in the C source via a
register-pinned alias.
