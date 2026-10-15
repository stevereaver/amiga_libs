---
type: Function
title: LibExpunge
description: Remove + free the base when open count is zero, else defer.
lvo: -18
timestamp: 2026-10-10T09:40:00Z
---

# Signature

```c
BPTR LibExpunge(struct XpkSubBase *base);  /* a6 -> d0 */
```

# Semantics

`tst.w lib_OpenCnt`; nonzero → `bset #3,lib_Flags` and return 0 via
the shared stub. Zero → stack seglist + base pointer, `a6 = *(4).w`,
`Remove(base)`, `FreeMem(base - NegSize, NegSize + PosSize)`, restore
and return seglist. Slightly different register juggling than the
xpkNONE skeletons (uses the stack rather than d2/a5). .text+0xf8.
