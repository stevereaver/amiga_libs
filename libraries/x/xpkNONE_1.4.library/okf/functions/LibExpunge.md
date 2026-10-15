---
type: Function
title: LibExpunge
description: Remove node, free base block, return seglist.
lvo: -18
timestamp: 2026-10-10T19:45:00Z
---

# Signature

```c
APTR LibExpunge(struct XpkSubBase *base);  /* a6 -> d0 */
```

# Semantics

- Sets LIBF_DELEXP (`bset #3,lib_Flags`) **unconditionally**, before
  testing `lib_OpenCnt` — see
  [UnconditionalDelexp](../findings/UnconditionalDelexp.md).
- If `lib_OpenCnt != 0`: returns 0 (deferred).
- Otherwise: `Remove()` via the stored `xsb_SysBase`, saves
  `xsb_SegList`, `FreeMem()`s `base - NegSize` for `NegSize+PosSize`
  bytes (word reads), returns the seglist.
