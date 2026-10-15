---
type: Function
title: XpksPackReset (LVO -48)
---

# XpksPackReset — xpkILZR 1.2

`d0 = xsp_Sub[1]` (head table); NULL → rts.
Else clears **65536 bytes** from the head base (`d1 = -1`,
`bcc` countdown) — byte-wise `clr.b (a0)+`.

The chain table (`xsp_Sub[0]`) is never cleared — not here,
not in PackChunk's init path.  Stale chain links persist
across chunks; they are only filtered by the monotonic
`d4 >= d3` check and the 18-failure budget.
