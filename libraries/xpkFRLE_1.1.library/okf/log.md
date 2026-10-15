---
type: Log
title: Work Log
description: Chronological journal of analysis sessions. Newest first.
---

# Log

## 2026-10-10
- Parsed 884-byte single-CODE-hunk module: entry `moveq #-1,d0/
  rts`, RomTag (AUTOINIT, ver 1), InitTable at +0x1e
  (dataSize 0x26, word-offset functab at +0x2e with -1 markers,
  datatab +0x46, initFunc +0x15e), strings, XpkInfo (+0x66) and
  XpkMode (+0xbe).
- Vectors (word offsets from functab): Open 0x138, Close 0x146,
  Expunge 0x154, null stub 0x18a (ExtFunc/PackFree/PackReset/
  UnpackFree), PackerInfo 0x18e, PackChunk 0x196, UnpackChunk 0x276.
- Codec decoded: header XOR scheme — literal (len-1)^0x1f with
  len <= 128, repeat (n-2)^0x9f, no terminator; decoder formula
  n = (h&0x7f) - 2*(h&0x1f) + 0x20/0x21 verified by algebra.
- Found latent defects: literal budget permits ~130-byte chunks
  overflowing the header into the repeat range (corrupt stream on
  inputs with >128 non-repeating bytes); literal scanner reads
  past input end; last-byte n=1 run can emit invalid header 0x60;
  repeat emit checks 1 byte headroom but writes 2.
- Reconstructed in C (bounded reads, 128-byte literal cap — same
  decoded output on all inputs), built, 20k round-trip test pass.
- Filed inconsistency card AMIGALIBS-23.

## 2026-10-15
- Byte-verbatim asm reconstruction (`source/xpkFRLE_h0.s`) +
  descending-RELOC32 fixup.py; `cmp` byte-identical
  (md5 45381000923f1a67ca73aad8526201ff).
- machine68k oracle (work/oracle.py): identical logs orig vs
  rebuild across init, all vectors, codec edge cases and the
  real deferred-expunge path.
- New quirks found while transcribing: `eor.b d2,d5` corrupts
  the literal key in the tail-literal emit (dead register);
  decoder uses +0x20 bias for repeats vs +0x1f for literals;
  pack stores outlen via `suba.l -8(a0),a3; move.l a3,(a0)`
  vs unpack's `suba.l -(a0),a3; move.l a3,8(a0)`; pack bounds
  output by OutBuf+OutBufLen (-17) while unpack is unbounded;
  functab physically precedes datatab; RELOC32 tail is
  descending (18 sites).
