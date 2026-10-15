---
type: Function
title: LibOpen
description: lib_OpenCnt++, returns the library base. No DELEXP handling.
lvo: -6
registers: -
---

# `struct Library *LibOpen(void)`

**LVO -6** — implicit `a6` = library base.

The entire function is three instructions (text+0x8c):

```
addq.w  #1,32(a6)   ; lib_OpenCnt++
move.l  a6,d0
rts
```

Unlike most Commodore libraries it does **not** clear
`LIBF_DELEXP` — see [CloseSemantics](../findings/CloseSemantics.md).
