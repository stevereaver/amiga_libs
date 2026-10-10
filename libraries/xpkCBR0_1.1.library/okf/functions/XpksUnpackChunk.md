---
type: Function
title: XpksUnpackChunk
description: RLE decoder.
---

# XpksUnpackChunk — LVO -54

`LONG XpksUnpackChunk(struct XpkSubParams *a0)` —
expands a0@[0]/a0@[4] into a0@[8], writes the unpacked
length to a0@[16] and returns 0.

Header <0x80: literal h+1 bytes; header >=0x80: repeat
the next byte 257-h times.  Output bound is
dst+256+params[3], checked per emitted byte (-10 past
it).  Input >= 0xfffc -> -11; empty input -> outlen 0,
return 0.
