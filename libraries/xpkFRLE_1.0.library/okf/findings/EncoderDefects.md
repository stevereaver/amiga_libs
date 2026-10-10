---
type: Finding
title: Latent encoder quirks
description: Reachable edge cases in the shipped FRLE 1.0 encoder.
---

# Latent encoder quirks

All confirmed by tracing the shipped code (hunk +0x116):

1. **Out-of-bounds input reads.**  The head pair check, the
   127-compare run block and the literal state machine all read
   `(a1)+` with no end test; correctness is rescued only by
   emit-time clamping against the input end.  Up to ~129 bytes
   past the buffer may be read.  An OOB byte equal to the last
   input byte can start a phantom run (emitted clamped), and an
   OOB 3-equal-byte stretch ends a literal early — both only
   affect segmentation, not decode integrity, *unless* a run of
   length 1 is emitted (see 3).
2. **n=1 run -> invalid header.**  If the input's last byte
   equals the OOB byte just past the buffer, a run starting at
   `srcend-1` is emitted with n=1: header `(1-2)^0x9f` =
   `0xff^0x9f` = 0x60 -> a literal-128 header -> the decoder
   consumes 128 further bytes and the stream desyncs.
   Requires an out-of-bounds byte coincidence.
3. **Repeat emit checks 1 byte, writes 2.**  `cmpa.l a4,a2` is
   the only space test before the 2-byte repeat record; with
   `out == dstlim-1` the record overflows OutBufLen by one byte.
4. **Literal capacity check uses the unclamped scanned length.**
   `lea a2@(1,d2),a6; cmpa.l a4,a6` runs before the srcend
   clamp, so tail literals are charged for the full OOB-scanned
   length (~128 bytes) — pack can return -17 although the
   clamped literal would have fit.
5. **No output bounds in the decoder** and no input validation —
   corrupt/truncated streams read and write past both buffers.

Notably absent vs 1.1/1.2: **no** literal-overflow corruption
(the state machine's worst case lands exactly on 128) and
**no** missing `xsp_OutLen` write on unpack.

## Reconstruction divergence

`source/xpkFRLE.c` bounds all input reads; emitted streams are
identical on every input where the original's OOB reads did not
coincidentally match (equal OOB bytes could shift token
boundaries or trigger quirk 2 in the original).
