---
type: Function
title: XpksPackReset (LVO -48)
---

# XpksPackReset

No-op when `xsp_Sub[0]==0`.  Otherwise clears the 64KB
`head[]` table: a movem fill writes 65536 bytes downward
from `workmem+0x10004` to `workmem+4` (315 iterations * 208
bytes + a 16-byte tail), leaving the 4-byte size prefix
intact.

The `chain[]` table is NOT cleared — stale links are
harmless because every `chain[p]` write overwrites before
any read can reach it through a still-live head entry.
