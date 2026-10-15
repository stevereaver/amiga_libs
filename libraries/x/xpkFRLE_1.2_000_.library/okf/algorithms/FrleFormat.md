---
type: Algorithm
title: FrleFormat
description: XOR-obfuscated ByteRun stream format.
---

# FRLE stream format

Unchanged from V1.1 -- the decoder math is identical:

- header h < 0x80: literal of `32-(h&31)+32*(h>>5)` bytes
  (= h+... equivalently `h - 2*(h&0x1f) + 0x20`), followed
  by that many raw bytes
- header h >= 0x80: repeat of `33-(h&31)+32*((h&127)>>5)`
  times the next byte (`(h&0x7f) - 2*(h&0x1f) + 0x21`)
- no terminator -- decode stops at input exhaustion
- ranges: literals 1..129 bytes, repeats 2..129 bytes

Encoder emit forms:

    literal n:  hdr = (n-1) ^ 0x1f
    repeat  n:  hdr = (n-2) ^ 0x9f

The XOR scatters the count bits so bit7 is a clean
repeat/literal flag while the low 5 bits hold
`33-count mod 32` and bits 5-6 the 32-block count -- which
is exactly the (skip,blocks) pair the unrolled decoder
needs.  "Cache-optimized" marketing aside, it IS a neat fit
for the computed-goto decoder.