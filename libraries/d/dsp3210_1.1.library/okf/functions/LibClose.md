---
type: Function
title: LibClose
description: Over-close-safe skeleton close.
lvo: -12
timestamp: 2026-10-10T20:10:00Z
---

# Signature

```c
APTR LibClose(struct DSP3210Base *base);  /* a6 -> d0 */
```

# Semantics

Unusual defensive variant: `tst.w lib_OpenCnt` **before** decrementing
— a Close on an already-zero library returns NULL instead of running
the count negative. Then the standard path: decrement; on reaching
zero with LIBF_DELEXP set, call [LibExpunge](LibExpunge.md) (result
discarded — Close always returns 0 here). See
[OverCloseCheck](../findings/OverCloseCheck.md).
