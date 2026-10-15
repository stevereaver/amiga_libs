---
type: Algorithm
title: RLEN codec
description: PackBits-style byte RLE — code byte then payload, 0 terminator.
timestamp: 2026-10-10T09:40:00Z
---

# RLEN codec

## Stream format

| code byte | meaning |
|----------:|---------|
| 0x01..0x7f | literal run: copy the next `code` input bytes verbatim |
| 0x81..0xff | repeat run: emit the next byte `-code` times (2..127) |
| 0x80 | degenerate: emits the byte once via a `neg.b`/`bgt` overflow (see [Decoder80](../findings/Decoder80.md)) |
| 0x00 | end of stream |

Runs are limited to 127 in both directions; a repeat run needs at
least three equal bytes to be emitted (runs of two stay literal — the
encoder only detects runs of ≥3 and `2×overhead` would make 2-byte
repeats a wash anyway).

## Encoder ([XpksPackChunk](../functions/XpksPackChunk.md))

Greedy single pass. Invariants: `lit` marks the first not-yet-emitted
literal byte, `pend = src - lit`, `runlen` = detected run prefix at
`src` (0 or ≥2).

- Each iteration peeks `src[0..2]`; three equal bytes seed a repeat
  run (`runlen=2`).
- Literals extend until `pend==127`, a run is found, or input ends.
- Before *every* emit decision the encoder checks
  `out + 4 + pend > outlim → XPKERR_EXPANSION` — a conservative
  reserve (see [LiteralReserve4](../findings/LiteralReserve4.md)).
- Repeat runs extend while equal and `< 0x7f`, then emit
  `(-len, byte)`.
- Terminated by a `0x00` byte; `xsp_OutLen` = produced length.

## Decoder ([XpksUnpackChunk](../functions/XpksUnpackChunk.md))

Byte-at-a-time state machine, `code>0` copy / `code<0` repeat /
`code==0` stop. No output bounds checking.
