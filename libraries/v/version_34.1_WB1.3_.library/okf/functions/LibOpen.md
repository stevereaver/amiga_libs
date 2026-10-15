---
type: Function
title: LibOpen
description: OpenCnt++, clears the deferred-expunge flag, returns the library base.
lvo: -6
registers: a6=library base
timestamp: 2026-10-10T19:00:00Z
---

# `struct Library *LibOpen(void)`

**LVO -6** — `a6` = library base on entry (jump-table dispatch).

```
addq.w  #1,32(a6)        | lib_OpenCnt++
bclr    #3,42(a6)        | clear deferred-expunge flag (base+42, bit 3)
move.l  a6,d0            | return the base
rts
```

The deferred-expunge flag is kept in a private byte at base+0x2a,
not in `lib_Flags`.
