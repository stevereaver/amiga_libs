---
type: Function
title: XpksPackChunk (LVO -36)
---
# XpksPackChunk

Reads xsp_Mode and dispatches against the xm_Upto values:

- <=33: LongByte encoder (tag 33, minrun 8, cap inlen,
  4-byte counts)
- <=67: WordByte (tag 67, minrun 5, cap 0x8000, 2-byte)
- <=90: ByteByte (tag **90**, minrun 3, cap 0x80, 1-byte)
- >90: AutoSize (trial all three, keep smallest)

Encoder core (shared): emits the tag byte, then scans for
>=3-byte runs vs literal stretches (cmpmb pair-detection),
emitting literals only when a run >= minrun is found or
the input ends. Pending literal state: d3 count, a6
start. Bound: -17 after data-byte writes when w reaches
dst+inlen; count writes unbounded.
