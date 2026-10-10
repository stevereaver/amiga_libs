---
type: Library
title: xpkFBR2.library V4.1 "FastBytesRunner"
description: >-
  Niels Froehling XPK sublibrary implementing a multi-mode
  byte-run RLE (LongByte/WordByte/ByteByte count widths +
  AutoSize trial mode).  AUTOINIT word-offset functab,
  0x26-byte base, static XpkInfo+XpkMode descriptors.
  V4.1 ships a broken ByteByte stream tag (90 emitted,
  100 expected by the decoder) so ByteByte/default-mode
  output is undecodable by the library itself.
timestamp: 2026-10-28T00:00:00Z
---

# xpkFBR2.library V4.1

"FastBytesRunner" XPK sublibrary (1 Oct 2013) — RLE with
three count-field widths and an AutoSize trial mode.
Stream: `<tag>{<signed count><payload>}*`; positive
counts repeat the next byte count+1 times, negative
counts copy 1-count literals.

## Binary facts

- 1328 bytes, single CODE hunk
- RomTag: RTF_AUTOINIT, RT_VERSION 4, NT_LIBRARY
- entry stub `moveq #0,d0; rts` (also the null vector)
- functab: word-offset, 10 vectors; nulls point at hunk+0
- dataSize 0x26 (seglist only at base+0x22)
- descriptors are STATIC data in the hunk (PackerInfo lea)
- sha256: see log.md

## Vectors

| LVO | Function | Notes |
|-----|----------|-------|
| -6  | LibOpen | standard |
| -12 | LibClose | DELEXP bit 3 handled correctly |
| -18 | LibExpunge | Remove+FreeMem |
| -24 | _start | null (ExtFunc) |
| -30 | XpksPackerInfo | -> static XpkInfo |
| -36 | XpksPackChunk | mode dispatch + AutoSize |
| -42 | _start | null (PackFree) |
| -48 | _start | null (PackReset) |
| -54 | XpksUnpackChunk | tag dispatch + decoder |
| -60 | _start | null (UnpackFree) |

## External calls

exec.library: Remove (-252), FreeMem (-210) — expunge only.

## Reconstruction

- `source/xpkFBR2.c` — framework + codec
- `source/xpkFBR2_lib.s` — RomTag/AUTOINIT + static descriptor
- two-pass word-offset functab (genfunctab.py)
- Host test: 10002 round-trips pass, 0 failures;
  9990 tag-90 streams correctly rejected (-12)
