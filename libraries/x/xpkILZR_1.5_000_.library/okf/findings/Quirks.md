---
type: Finding
title: xpkILZR quirks & defects
---

# Quirks & defects

## 1. chain[] overflows for InLen > 0x4000 (latent)

`chain[]` is only 0x4000 words (16KB) but positions are
indexed by the full input offset.  `XpksPackChunk` writes
`chain[pos]` for every pos — past the workmem block once
pos >= 0x4000.  Only `xi_MaxPkInChunk=0x4000` stops real
inputs from corrupting the heap.  Masked, not fixed.

## 2. XpksPackFree leaves xsp_Sub[0] dangling

Frees the block but never clears the pointer; a later pack
skips the AllocMem and writes into freed memory
(use-after-free).  Latent — PackFree is normally a teardown
call.

## 3. Hash seed reads in[0]/in[1] unconditionally

`hash = (in[0]<<5 ^ in[1])&0x7fff` runs even for InLen<2 —
reads OOB for empty/1-byte inputs (value unused on the
literal-only tail path, but read).  For InLen=0 the stream
still emits one literal of the OOB-read byte — same class
as the FBR2 empty-input quirk.

## 4. Precheck & cmpm scan read past InLen

`in[cur+best]` precheck and the 18-iteration compare can
read up to ~18 bytes past the input end.  Values only
prune/cap the match — never emitted — but the bytes are
touched.

## 5. Write-then-check output guard

The bit writer stores the byte then tests `a6 < out+inlen`;
the boundary byte is already written when -17 returns, and
the final pad byte is never checked.

## 6. Decoder has no output bound

A terminal match longer than the remaining count copies
the full `len` anyway — overwrites past the declared
outlen.  Relies on honest streams (the -14 check only
gates the declared header vs xsp_OutLen).

## 7. Null vectors share the entry stub via a BACKWARD offset

ExtFunc (-24) and UnpackFree (-60) don't get their own
routine — the functab stores `ff72` (=-0x8e) pointing back
at `moveq #0,d0;rts`.  Unusual but works; the
reconstruction reproduces it (our offsets differ — -0x198
— because the table sits elsewhere in the hunk).

## 8. xsp_OutLen is never written by the decoder

Unlike most sublibs, the decoder only *reads* xsp_OutLen
(for the -14 gate); the caller must derive the produced
count itself.  xsp_OutBufLen is entirely ignored — the
pack bound is `out+inlen`, the unpack bound is nothing.
