---
type: Algorithm
title: CBR0Format
description: Byte-oriented RLE with signed header bytes.
---

# CBR0 packed format

Stream = sequence of runs, no terminator (decoder stops
at input exhaustion):

| header h | meaning | length |
|----------|---------|--------|
| 0x00..0x7f | literal: h+1 raw bytes follow | 1..128 |
| 0x80..0xff | repeat: next byte emitted 257-h times | 2..129 |

Decoder bounds output at dst+256+params[3] (-10 past it);
encoder additionally aborts when output reaches
dst+insize (-17 expansion guard) and refuses inputs
>= 0xfffc (-11).

Encoder policy: any equal pair (>=2 bytes) becomes a
repeat run, even mid-literal; runs emit in <=128-byte
segments so a long run produces several headers.
