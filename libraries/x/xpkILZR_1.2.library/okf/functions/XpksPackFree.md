---
type: Function
title: XpksPackFree (LVO -42)
---

# XpksPackFree — xpkILZR 1.2

```
clr.l 52(a0)    ; xsp_Sub[0] = 0 (chain)
clr.l 56(a0)    ; xsp_Sub[1] = 0 (head)
rts
```

**Leaks both workmem blocks** — the pool sub-allocator's
links stay on the freelist at base+0x110 forever; nothing
is freed.  0x18028+ bytes per open/close cycle on the
master copy's account.  Shipped as-is.
