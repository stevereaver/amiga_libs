---
type: Function
title: LibOpen
description: Increments lib_OpenCnt, clears LIBF_DELEXP, returns base.
lvo: -6
timestamp: 2026-10-10T09:40:00Z
---

# Signature

```c
struct Library *LibOpen(struct XpkSubBase *base);  /* a6 -> d0 */
```

# Semantics

`addq.w #1,lib_OpenCnt` then `bclr #3,lib_Flags` then `move.l a6,d0;
rts`. .text+0xdc.
