---
type: Algorithm
title: FRLE stream format
description: XOR-obfuscated ByteRun variant — "cache-optimized RLE".
timestamp: 2026-10-10T22:45:00Z
---

# FRLE stream format

Two record types, no terminator (stream ends at input exhaustion):

| record | header byte | payload |
|---|---|---|
| literal | `(len-1) ^ 0x1f`, len 1..128 | len raw bytes |
| repeat  | `(n-2) ^ 0x9f`, n 2..129 | 1 byte |

Bit7 of the header selects repeat (set) vs literal (clear).  The
XOR spreads the count across the low bits so the decoder needs the
inverse rather than a shift:

- literal: `n = h - 2*(h&0x1f) + 0x20`
- repeat:  `n = (h&0x7f) - 2*(h&0x1f) + 0x21`

The formula inverts `k^c` because `(k^m)&0x1f = m-(k&0x1f)` for
m=0x1f, so `n = (k&~0x1f | (m-(k&0x1f))) - 2*(m-(k&0x1f)) + bias`
collapses back to `k+1`/`k+2`.  Valid only while bit7 of
`k^mask` has the intended value — literals must satisfy len<=128
and repeats n<=129 for the encoding to survive.

## Encoder policy

- A repeat run is emitted for **2+** equal bytes at a segment
  start, but mid-literal only a **3+** equal-byte run ends the
  literal (an isolated pair stays literal) — asymmetric.
- Repeat runs cap at n=129 (budget counter 126 over reads past
  the first two).
- Literal chunks cap nominally at ~128 bytes but the budget is
  counted in 4-byte groups, so 129-130 byte literals are
  reachable -> header overflow, see
  [EncoderDefects](../findings/EncoderDefects.md).
- No expansion check: a pathological stream can grow the data.
