---
type: Algorithm
title: UnrolledDecoder
description: V1.2's computed-goto 32-byte store loops.
---

# V1.2 decoder trick

For each header, the decoder computes:

    d0 = h * 2            (add.b d0,d0; carry = bit7)
    d1 = d0 & 0x3e        -> byte offset into the store block
    d0 = d0 >> 6 (word)   -> number of extra 32-store blocks
    jmp pc@(block + d1)   -> skip (32 - d1/2) stores
    dbf d0, block         -> repeat full 32-byte blocks

Literal block: 32 x `move.b (a0)+,(a2)+`
Repeat block:  32 x `move.b d2,(a2)+` + one trailing store

So the count encoded in the header is literally
(skip,32-blocks): the XOR header format is designed for this
decode path.  ~50 instructions of straight-line stores per
segment instead of a byte loop -- the V1.2 speed win.

No bounds checking anywhere: a literal header at input end
reads past InBuf, and nothing checks OutLen against
OutBufLen.  xsp_OutLen is never written (xpkmaster knows the
unpacked size from the chunk header).