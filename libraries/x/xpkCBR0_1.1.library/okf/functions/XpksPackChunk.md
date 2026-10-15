---
type: Function
title: XpksPackChunk
description: RLE encoder.
---

# XpksPackChunk — LVO -36

`LONG XpksPackChunk(struct XpkSubParams *a0)` —
compresses a0@[0]/a0@[4] into a0@[8], writes the packed
length to a0@[16] and returns 0.

Per segment: two equal bytes open a repeat run emitted
in <=128-byte pieces (header 257-n, then the byte);
otherwise a literal of <=128 bytes is gathered, ending
before an equal pair (header n-1).

Guards: input >= 0xfffc -> -11; output passing
dst+256+params[3] -> -10; output reaching dst+insize
-> -17 (expansion bail-out — xpkmaster stores the chunk
uncompressed).  See algorithms/CBR0Format.md and
findings/EncoderDefects.md.
