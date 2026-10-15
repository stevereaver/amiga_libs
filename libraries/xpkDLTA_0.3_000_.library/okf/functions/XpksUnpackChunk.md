---
type: Function
title: XpksUnpackChunk
description: Byte-delta decode one chunk (accumulate).
lvo: -54
---

# Signature

```c
LONG XpksUnpackChunk(struct XpkSubParams *xsp /* a0 */,
                     struct XpkSubBase *base /* a6 */);  /* -> d0 */
```

# Semantics

Reads `xsp_InBuf`/`xsp_InLen`/`xsp_OutBuf`, writes
`out[i] = out[i-1] + in[i]` (mod 256), returns 0 always.
**Quirk: `xsp_OutLen` is never written** — the caller keeps whatever
it passed in.  See [algorithms/codec.md](../algorithms/codec.md).
