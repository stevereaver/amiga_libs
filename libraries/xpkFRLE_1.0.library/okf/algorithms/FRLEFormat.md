---
type: Algorithm
title: FRLE stream format
description: XOR-obfuscated ByteRun — literal (n-1)^0x1f, repeat (n-2)^0x9f.
---

# FRLE stream format

Two record types, no terminator (stream ends at InLen):

| Header byte h     | Meaning   | Payload   | Length n                          |
|-------------------|-----------|-----------|-----------------------------------|
| h <  0x80         | literal   | n bytes   | `32 - (h&0x1f) + 32*(h>>5)`       |
| h >= 0x80         | repeat    | 1 byte    | `33 - (h&0x1f) + 32*((h&0x7f)>>5)`|

Encoder inverse: literal header = `(n-1)^0x1f` (n = 1..128),
repeat header = `(n-2)^0x9f` (n = 2..129).  The XOR scatters the
length bits while bit7 remains a clean repeat flag — the vendor's
"cache-optimized" claim.  Identical to FRLE 1.1/1.2 streams.

## Encoder state machines (V1.0)

**Run scan.**  Triggered when the two head bytes at a segment
start are equal (a run may be as short as 2 at a segment start).
An unrolled `cmp.b (a1)+,d0` block — 15 compares on entry plus
7 full 16-compare passes (d3=7) — counts at most 127 further
equal bytes -> run length <= 129.

**Literal scan.**  A four-phase state machine over a sliding
one-byte window (d0,d1); each phase reads one byte and compares
it to the previous.  An equal pair enters a confirm path
(P1..P4) reading a third byte: three equal bytes end the
literal three bytes back (requiring 3-in-a-row mid-literal vs 2
at a segment start).

The d3=31 budget is decremented once per cycle at three exits;
a P4-exhaust additionally retreats a1 by one.  Reads per cycle
vary 2..5 by path, but the maximum total advance is provably
128 bytes: every P4 cycle nets at most 4 reads (its extra
confirm read is cancelled at exhaust or by the L3-entry cap),
so `(len-1)^0x1f` can never overflow into bit7 — the tight
design the rewrites (1.1/1.2) subsequently lost.

## Decoder trick

Computed-goto (`jmp pc@(block, 2*(h&0x1f))`) into 32-entry
unrolled `move.b` store blocks, full blocks looped by dbf on
the `h>>5` field — the same technique the 1.2 rebuild adopted.
Unlike 1.2, this version writes `xsp_OutLen`.
