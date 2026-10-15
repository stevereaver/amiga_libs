---
type: Function
title: LibClose
description: OpenCnt--; expunges when the count reaches zero after a deferred expunge.
lvo: -12
registers: a6=library base
timestamp: 2026-10-10T19:00:00Z
---

# `BPTR LibClose(void)`

**LVO -12** — `a6` = library base on entry.

```
moveq   #0,d0
subq.w  #1,32(a6)        | lib_OpenCnt--
bne.s   done             | still open -> return 0
btst    #3,42(a6)        | deferred expunge pending?
beq.s   done
bsr.w   LibExpunge       | returns seglist in d0
done:
rts
```

Returns 0, or the library seglist when it was expunged.
