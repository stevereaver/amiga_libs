---
type: Finding
title: EncoderDefects
description: Out-of-bounds input read in XpksPackChunk.
---

# Encoder defects

1. **One-byte over-read at input end.**  The
   literal-vs-run decision compares `src[1] == src[0]`
   via `cmpb a3@,d0` with `bhis` taking the branch when
   `srcend >= a3` — equality included.  When the current
   byte is the last input byte, `a3` equals `srcend` and
   the compare reads one byte past the buffer.  Read-only
   and harmless on Amiga (no page granularity issues at
   this scale); the C reconstruction bounds the peek and
   is behaviour-identical on valid input.

2. **Run length budget vs emitted header.**  Runs are
   emitted in <=128-byte segments but the repeat format
   itself supports 129; a 128-byte run gets header 0x81
   (decode 128) through the counter-underflow exit, not
   0x80 (decode 129).  Consistent, just non-obvious —
   the reconstruction emits `257 - n` for n <= 128 which
   reproduces the shipped header values exactly.
