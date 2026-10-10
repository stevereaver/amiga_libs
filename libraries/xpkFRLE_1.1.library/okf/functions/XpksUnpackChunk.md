---
type: Function
title: XpksUnpackChunk
description: FRLE decoder — header-driven copy/repeat loop, no bounds checks.
lvo: -54
registers: a0 XpkSubParams *, a6 base -> d0 0
timestamp: 2026-10-10T22:45:00Z
---

# ``LONG XpksUnpackChunk(struct XpkSubParams *p)``

**LVO -54**

Reads `xsp_InBuf`/`InLen`/`OutBuf`, writes `xsp_OutLen` (OutBufLen
is ignored — no output bounds checking at all).

```c
while (src < srcend) {
    h = *src++;
    if (h & 0x80) { n = (h&0x7f) - 2*(h&0x1f) + 0x21; repeat *src++; }
    else          { n =  h       - 2*(h&0x1f) + 0x20; copy literals; }
}
```

The stream has **no terminator** — it ends when InLen is consumed,
so InLen must be exact.  Malformed streams read past the input and
write past OutBuf unchecked.
