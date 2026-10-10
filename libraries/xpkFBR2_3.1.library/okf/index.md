---
type: Library
title: xpkFBR2.library V3.1 "FastByteRun"
description: >-
  Niels Froehling XPK sublibrary implementing a three-mode
  byte-run RLE (LongByte/WordByte/ByteByte count widths).
  AUTOINIT word-offset functab, 0x26-byte base, static
  XpkInfo + linked XpkMode descriptors.  All three stream
  tags are self-consistent (the V4.1 rewrite later broke
  ByteByte's), but the WordByte/ByteByte windowed scanner
  emits out-of-bounds input into the stream for inputs
  smaller than one window.
timestamp: 2026-10-28T00:00:00Z
---

# xpkFBR2.library V3.1

"FastByteRun" XPK sublibrary (3 May 2011) — RLE with three
count-field widths.  Stream: `<tag>{<signed count><payload>}*`;
positive counts repeat the next byte count+1 times, negative
counts copy 1-count literals.

## Binary facts

- 1380 bytes, single CODE hunk
- sha256: `04d91468ce18ca1c3bbc2270d275c4060b6cae965e5b4ac9c2f8a068e12e05de`
- RomTag: RTF_AUTOINIT, RT_VERSION 3, NT_LIBRARY
- entry stub `moveq #-1,d0; rts` (returns -1; V4.x uses 0)
- functab: word-offset, 10 vectors, `ffff` marker/terminator;
  the four null slots share one `moveq #0,d0; rts`
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
| -36 | XpksPackChunk | `cmpb` mode dispatch |
| -42 | LibNull | null (PackFree) |
| -48 | LibNull | null (PackReset) |
| -54 | XpksUnpackChunk | tag dispatch + decoder |
| -60 | LibNull | null (UnpackFree) |

Original functab words: `ffff 01ec 01fa 0208 023e 0242
024c 023e 023e 03d8 023e ffff` (word offsets x2 from the
marker at hunk+0x26).

## External calls

exec.library: Remove (-252), FreeMem (-210) — expunge only.

## Reconstruction

- `source/xpkFBR2.c` — framework + codec
- `source/xpkFBR2_lib.s` — RomTag/AUTOINIT + static descriptor
- two-pass word-offset functab (genfunctab.py)
- Host test: 5676 round-trips, 0 reconstruction errors;
  47 tail-drop and 200 empty-input outputs match the
  shipped machine exactly (see findings).
