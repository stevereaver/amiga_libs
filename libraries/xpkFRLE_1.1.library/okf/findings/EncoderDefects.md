---
type: Finding
title: Latent encoder defects
description: Reachable corruption cases in the shipped FRLE encoder.
timestamp: 2026-10-10T22:45:00Z
---

# Latent encoder defects

All confirmed by tracing the shipped code (hunk +0x1c4):

1. **Literal header overflow (corrupt output).**  The literal
   budget counts in 4-byte groups (d3=31 -> 32 units) after the
   first two bytes, so a literal chunk can reach 129-130 bytes.
   Header `(len-1)^0x1f` for len>128 sets bit7 -> the decoder
   treats it as a *repeat* record -> the stream is undecodable
   from that point.  Triggered by any >=130-byte stretch with no
   3-equal-byte run (e.g. `0,1,2,...,129`).
2. **Out-of-bounds input reads.**  The literal pair/triple
   scanner and the run counter read `(a1)+` with no end check;
   correctness is rescued only by emit-time clamping against the
   input end.  Up to ~128 bytes past the buffer may be read.
3. **n=1 run -> invalid header.**  If the input's last byte
   happens to equal the (OOB) byte just past the buffer, a run
   starting at srcend-1 is emitted with n=1: header
   `(1-2)^0x9f` = 0x60 -> a literal header claiming 128 bytes.
   Requires heap-byte coincidence; would corrupt the stream.
4. **Repeat emit checks 1 byte, writes 2.**  `cmpa.l a4,a3` is
   the only space test before the 2-byte repeat record; a full
   buffer minus one byte overflows OutBufLen by one.

The decoder is likewise unchecked: no output bounds, truncated
streams read past the input.

## Reconstruction divergence

`source/xpkFRLE.c` bounds all input reads and caps literals at
exactly 128 bytes.  Decoded output is identical on every input;
the emitted byte stream can differ from the original only in
cases where the original would have produced a corrupt stream
anyway (and at tail boundaries where OOB bytes influenced the
original's segmentation).
