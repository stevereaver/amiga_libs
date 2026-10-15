---
type: Algorithm
title: LIN2 stream format sketch
description: "Lino2" LZ scheme — distance-class bit packing, byte
  histogram table, trailer-carried decode tables.
---

# LIN2 ("Lino2 V1.1") codec sketch

LIN2 is a Lempel-Ziv variant by Gerhard Tuenkler, advertised in its
own descriptor as "Better version of Lino1". This file sketches the
stream structure as recovered from `XpksPackChunk` (code+0x13a) and
`XpksUnpackChunk` (code+0x75c); see `structures/layout.md` for the
workspace maps.

## Stream head

- bytes `[0:4]` — password hash (`0` when no password). The packer
  hashes `xsp_Password` with the string-hash helper at code+0xa74
  and stores it both here and at `xsp_Sub[3]` (+0x40). The unpacker
  rejects a non-zero head that does not equal the hash of its own
  `xsp_Password` (return `-32`).

## Token stream

- Hash-chain matcher: head table of `0x100<<submode` word entries
  (submode 5/6/7 from `xsp_Mode` <34/<67/else — PackMemory
  0x4900/0x8900/0x10900).
- Match distances are emitted through a distance-class scheme with
  class bounds {0,2,6,14,30,62,126,254,510} and per-class extra-bit
  counts stored in the workspace at +0x12..0x19 (recomputed each
  chunk; classes cover distances up to ~510 + wide escape).
- Literal coding is driven by a 256-long byte-frequency histogram
  (+0x020..0x41f) — a static table per chunk, not an online model.

## Trailer

- 16 code-length bytes (+0x100..0x10f of the pack workspace) are
  appended to the stream so the unpacker can rebuild its decode
  tables from the trailer alone — the unpack workspace itself is
  only 0x20 bytes (8-entry adaptive bound table + counts).
- Pack also writes the produced length to `xsp_OutLen` and fails
  with `-17` when the output did not shrink (`OutLen >= InLen`) or
  the `OutBuf+InLen` bound was hit mid-stream.

## Failure / boundary behavior

- `-7` — AllocMem of the pack workspace failed.
- `-14` — unpack produced a size different from preset
  `xsp_OutLen`.
- `-32` — password-hash mismatch.
- `xsp_Password` is dereferenced without a NULL check on the first
  PackChunk (see findings/quirks.md).
