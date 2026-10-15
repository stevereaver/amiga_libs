---
type: Function
title: LibExpunge
description: Removes the library node, frees the base block, returns the seglist.
lvo: -18
timestamp: 2026-10-10T19:15:00Z
---

# Signature

```c
APTR LibExpunge(struct FWFilterBase *base);  /* a6 -> d0 */
```

# Semantics

- If `lib_OpenCnt != 0`: sets LIBF_DELEXP (bit 3 of lib_Flags) and
  returns 0 — deferred expunge.
- Otherwise: saves the base in a2, loads ExecBase from `4.w`
  (ABSEXECBASE — the library keeps no SysBase field), calls exec
  `Remove` (-252) on the node, fetches the seglist via a private helper
  (returns `base + 0x24`), then `FreeMem` (-210) on
  `base - lib_NegSize` for `lib_NegSize + lib_PosSize` bytes (word reads).
- Returns the seglist. Standard skeleton.

# Notes

The seglist helper exists as a real subroutine (`jsr` target) in the
original rather than an inlined field read — reproduced as a comment
in the C source.
