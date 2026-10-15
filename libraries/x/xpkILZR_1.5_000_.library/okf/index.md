---
type: Library
title: xpkILZR.library V1.5 "Incremental LZ-Renau"
description: >-
  Jose Reanu XPK sublibrary implementing a hash-chain LZSS
  with an MSB-first bit stream and absolute-position match
  tokens (not distances).  AUTOINIT word-offset functab,
  0x26-byte base, static XpkInfo + single-node XpkMode.
  Workmem (0x18004 B) is lazily AllocMem'd; the chain table
  caps positions at 16K so MaxPkInChunk=0x4000 is the only
  thing keeping PackChunk from scribbling past the block.
timestamp: 2026-10-28T00:00:00Z
---

# xpkILZR.library V1.5

"Incremental LZ-Renau" XPK sublibrary (1 Oct 2013) — a
fast hash-chain LZSS variant.  Stream: `<outlen.w>{token}*`,
MSB-first bits; `1`+8-bit literal, `0`+pos(w bits)+len-3(4).
The `pos` field is an ABSOLUTE output index (decoder copies
`len` bytes from `out[pos]`), and its width `w` starts at 8
and grows as the output position crosses powers of two.

## Binary facts

- 1384 bytes, single CODE hunk
- sha256: `e5da00e5efb71a483e62a9e463b7e3166e7803a5e56255650a222cf3d4ba583e`
- RomTag: RTF_AUTOINIT, RT_VERSION 1, NT_LIBRARY
- entry stub `moveq #0,d0; rts` (also the null vector)
- functab: word-offset, 10 vectors, `ffff` marker/terminator;
  the two null slots use a BACKWARD offset to the entry stub
- dataSize 0x26 (seglist only at base+0x22)
- descriptors are STATIC data in the hunk (PackerInfo lea)

## Vectors

| LVO | Function | Notes |
|-----|----------|-------|
| -6  | LibOpen | standard |
| -12 | LibClose | DELEXP bit handled |
| -18 | LibExpunge | Remove+FreeMem |
| -24 | LibNull | null (ExtFunc) |
| -30 | XpksPackerInfo | -> static XpkInfo |
| -36 | XpksPackChunk | hash-chain LZSS encoder |
| -42 | XpksPackFree | frees workmem, leaves dangling ptr |
| -48 | XpksPackReset | clears head[] (movem fill) |
| -54 | XpksUnpackChunk | bit-reader decoder |
| -60 | LibNull | null (UnpackFree) |

Original functab words: `ffff 0020 002e 0040 ff72 00e6
00ee 007e 0096 02b2 ff72 ffff` (word offsets from the
marker; `ff72` = -0x8e backward to the entry stub).

## External calls

exec.library: Remove (-252) + FreeMem (-210) in expunge,
FreeMem (-210) in PackFree, AllocMem (-198) in PackChunk.

## Reconstruction

- `source/xpkILZR.c` — framework + codec
- `source/xpkILZR_lib.s` — RomTag/AUTOINIT + static descriptor
- two-pass word-offset functab (genfunctab.py)
- Host test: 3647 round-trips, 0 reconstruction errors;
  4353 `-17` rejects on incompressible data (correct).
