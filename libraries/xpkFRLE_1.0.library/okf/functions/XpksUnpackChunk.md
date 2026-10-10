---
type: Function
title: XpksUnpackChunk
description: FRLE decoder — computed-goto store blocks; writes xsp_OutLen.
lvo: -54
registers: a0 XpkSubParams *, a6 base -> d0 0
---

# ``LONG XpksUnpackChunk(struct XpkSubParams *p)``

**LVO -54** (hunk +0x242)

Reads `xsp_InBuf`/`InLen`/`OutBuf`, **writes `xsp_OutLen`**
(the 1.2 rebuild dropped this write).  `OutBufLen` is ignored —
no output bounds checking at all.

```c
while (src < srcend) {
    h = *src++;
    if (h & 0x80) { n = 33 - (h&0x1f) + 32*((h&0x7f)>>5); repeat *src++; }
    else          { n = 32 - (h&0x1f) + 32*(h>>5);        copy literals; }
}
```

The shipped code dispatches with `jmp pc@(block, 2*(h&0x1f))`
into unrolled blocks of 32 `move.b` stores (repeat block at
+0x25c, literal block at +0x2b8), then loops full blocks with
dbf on `(h>>5)`/`((h&0x7f)>>5)`.  `add.b d0,d0` doubles the
header so bit7 lands in carry for the repeat/literal test.

The stream has **no terminator** — it ends when InLen is
consumed, so InLen must be exact.  Malformed streams read past
the input and write past OutBuf unchecked.
