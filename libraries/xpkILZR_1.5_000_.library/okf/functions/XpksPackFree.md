---
type: Function
title: XpksPackFree (LVO -42)
---

# XpksPackFree

```
blk = xsp_Sub[0];
if (blk) FreeMem(blk-4, *(blk-4));
return 0;
```

Frees the lazily-allocated 0x18004-byte workmem.  The
original reads the size with `movel -(a1),d0` — a
pre-decrement that both fetches the prefix and points a1
at the block start for FreeMem.

**Defect:** xsp_Sub[0] is NOT cleared.  The pointer stays
dangling; a subsequent XpksPackChunk sees xsp_Sub[0]!=0,
skips the AllocMem, and writes into freed memory
(use-after-free).  Latent — the XPK host normally calls
PackFree only when unloading the sublibrary.
