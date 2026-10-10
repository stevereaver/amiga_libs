---
type: Function
title: XpksUnpackChunk
description: FRLE decoder.
---

# XpksUnpackChunk — LVO -54

`LONG XpksUnpackChunk(struct XpkSubParams *a0)` —
loads InBuf/InLen/OutBuf, iterates headers to input end:

- bit7 set: repeat `33-(h&31)+32*((h&127)>>5)` times next byte
- bit7 clear: literal `32-(h&31)+32*(h>>5)` following bytes

The store loops are computed-goto: `h*2 & 0x3e` selects the
entry point into a block of 32 unrolled `move.b` stores,
`h>>5` (word) is the dbf count of full 32-byte blocks (plus a
final store for repeats).  No output bounds checks, no
xsp_OutLen write.  Returns 0.
