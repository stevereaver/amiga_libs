---
type: Function
title: XpksUnpackChunk
description: Byte-delta decode one chunk (accumulate, with carry and bounds checks).
lvo: -54
---

# Signature

```c
LONG XpksUnpackChunk(struct XpkSubParams *xsp /* a0 */,
                     struct XpkSubBase *base /* a6 */);  /* -> d0 */
```

# Semantics

Inverse of [XpksPackChunk](XpksPackChunk.md): `out[i] = out[i-1] +
in[i]` (mod 256), same -10/-11 guards, same `xsp_Sub[0]`/`xsp_Sub[1]`
carry, same off-by-one (reads/writes InLen+1 bytes).
Its exit block (`movea.l (sp)+,a2; rts` at code+0x252) is shared —
PackChunk's error paths branch forward into it.
