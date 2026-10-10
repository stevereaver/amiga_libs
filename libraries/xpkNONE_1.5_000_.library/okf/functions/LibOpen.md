---
type: Function
title: LibOpen
description: Increments lib_OpenCnt, clears LIBF_DELEXP, returns base.
lvo: -6
timestamp: 2026-10-10T09:20:00Z
---

# Signature

```c
struct Library *LibOpen(struct XpkSubBase *base);  /* a6 -> d0 */
```

# Semantics

`addq.w #1,lib_OpenCnt` then `bclr #3,lib_Flags` then `move.l a6,d0;
rts`. The increment precedes the flag clear in this build (opposite
order to the 1.4 skeleton; immaterial). 11 bytes at .text+0xb2.
