---
type: Function
title: XpksPackChunk
description: Always fails with XPKERR_EXPANSION — "NONE" never packs.
lvo: -36
timestamp: 2026-10-10T09:20:00Z
---

# Signature

```c
LONG XpksPackChunk(struct XpkSubParams *xsp /* a0 */,
                   struct XpkSubBase *base /* a6 */);  /* -> d0 */
```

# Semantics

`moveq #-17,d0; rts` — returns `XPKERR_EXPANSION`. Storing raw data can
only expand it, so the sublibrary never packs; xpkmaster stores the
chunk uncompressed itself. .text+0x118.
