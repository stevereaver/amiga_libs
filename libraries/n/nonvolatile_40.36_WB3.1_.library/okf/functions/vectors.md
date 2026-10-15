---
type: Functions
title: nonvolatile 40.36 vector map
---

# Vector map (functab h0+0x2e, word-offset, 11 entries)

offsets relative to the table base (0x2e):
-6 0x074 Open · -12 0x0f4 Close · -18 0x122 Expunge ·
-24 0x192 · -30 0x5fc GetNVList · -36 0x668 ·
-42 0x4e8 · -48 0x68a · -54 0x1f8 · -60 0x29c · -66 0x488

Under stubs: most vectors return 0x10 (buffer/size arg echo)
or 0; -36 frees a scratch buffer.
