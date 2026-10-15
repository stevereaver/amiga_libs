---
type: Function
title: XpksUnpackChunk
description: RLE decoder — no output bounds checking at all.
lvo: -54
timestamp: 2026-10-10T09:40:00Z
---

# Signature

```c
LONG XpksUnpackChunk(struct XpkSubParams *xsp /* a0 */,
                     struct XpkSubBase *base /* a6 */);  /* -> d0 */
```

# Semantics

a1=`xsp_InBuf`, a0=`xsp_OutBuf`. Loop: read code byte d0; `0` → done
(return 0 via the shared stub); `d0<=0` → read repeat byte d1,
`neg.b d0`, if still `<=0` (only possible for code 0x80) skip, else
emit d1 d0 times; `d0>0` → copy d0 literal bytes. .text+0x132.

- `xsp_OutBufLen` is never consulted — a corrupt stream overflows the
  output buffer (see [NoOutputBounds](../findings/NoOutputBounds.md)).
- `xsp_OutLen` is not written; the master supplies the expected size.
- Code 0x80 (-128) decodes to *nothing* (see
  [Decoder80](../findings/Decoder80.md)).
