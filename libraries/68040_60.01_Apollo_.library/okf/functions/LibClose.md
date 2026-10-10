---
type: Function
title: LibClose
description: OpenCnt--, falls through into the expunge stub (returns 0).
lvo: -12
registers: a6 = library base (in), d0 = 0 (out)
---

# `LONG LibClose(void)`

**LVO -12**

```
subq.w #1,(32,a6)   ; lib_OpenCnt--
; falls through to LibExpunge:
moveq  #0,d0
rts
```

Never expunges, never closes the pre-opened library.
