---
type: Function
title: LibExpunge
description: Remove + free the base when open count is zero, else defer.
lvo: -18
timestamp: 2026-10-10T09:20:00Z
---

# Signature

```c
BPTR LibExpunge(struct XpkSubBase *base);  /* a6 -> d0 */
```

# Semantics

`tst.w lib_OpenCnt` first: nonzero → `bset #3,lib_Flags` (defer) and
branch to the shared return-0 stub. Zero → save d2/a5-a6, stash
`xsb_SegList` in d2, `a6 = *(4).w` (ExecBase from absolute 4.W — not
from the base), `Remove(base)`, then `FreeMem(base - NegSize,
NegSize + PosSize)` (word reads of lib_NegSize/lib_PosSize), restore
regs, return the seglist in d0. .text+0xd2.
