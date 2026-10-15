---
type: Function
title: XpksPackChunk
description: Byte-delta encode one chunk (1:1 filter).
lvo: -36
---

# Signature

```c
LONG XpksPackChunk(struct XpkSubParams *xsp /* a0 */,
                   struct XpkSubBase *base /* a6 */);  /* -> d0 */
```

# Semantics

Reads `xsp_InBuf`/`xsp_InLen`/`xsp_OutBuf`, writes
`xsp_OutLen = xsp_InLen`, delta-encodes (`out[0]=in[0]`,
`out[i]=in[i]-in[i-1]`), returns 0 always.  See
[algorithms/codec.md](../algorithms/codec.md).  No OutBufLen or 64K
checks, no cross-chunk state (both dropped vs 0.2); InLen==0 runs away.
