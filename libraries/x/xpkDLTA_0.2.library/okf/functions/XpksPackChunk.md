---
type: Function
title: XpksPackChunk
description: Byte-delta encode one chunk (1:1 filter, with carry and bounds checks).
lvo: -36
---

# Signature

```c
LONG XpksPackChunk(struct XpkSubParams *xsp /* a0 */,
                   struct XpkSubBase *base /* a6 */);  /* -> d0 */
```

# Semantics

Reads `xsp_InBuf`/`xsp_InLen`/`xsp_OutBuf`/`xsp_OutBufLen` and the
`xsp_Sub[0]`/`xsp_Sub[1]` carry pair; writes `xsp_OutLen = xsp_InLen`
and the delta stream (`out[0]=in[0]`, `out[i]=in[i]-in[i-1]`).
Returns 0, or -10 (InLen > OutBufLen) / -11 (InLen > 64K).  Quirk:
the loop is off-by-one — InLen+1 bytes are actually read/written.
See [algorithms/codec.md](../algorithms/codec.md) and
[findings/Quirks.md](../findings/Quirks.md).
