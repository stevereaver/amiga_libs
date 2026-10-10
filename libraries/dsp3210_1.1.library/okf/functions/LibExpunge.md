---
type: Function
title: LibExpunge
description: Standard skeleton expunge using 4.w SysBase.
lvo: -18
timestamp: 2026-10-10T20:10:00Z
---

# Signature

```c
APTR LibExpunge(struct DSP3210Base *base);  /* a6 -> d0 */
```

# Semantics

Standard: defer with LIBF_DELEXP while open; else `Remove` + `FreeMem`
(NegSize+PosSize, word reads) through SysBase at `4.w`, return
`db_SegList`.
