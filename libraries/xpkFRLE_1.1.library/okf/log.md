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
