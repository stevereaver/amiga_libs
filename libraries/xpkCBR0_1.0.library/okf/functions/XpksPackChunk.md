---
type: Function
title: XpksPackChunk (LVO -36)
---
# XpksPackChunk

RLE encoder.  `a0` = XpkSubParams; `a6` = base (unused).

- insize 0 -> OutLen=0, return 0
- insize > 0xfffc -> -11
- bounds: -10 at `dst+0x100+OutBufLen`, -17 at `dst+insize`
- run emit checks `w+2 >= bound` / `w+2 >= explim` (BHS);
  the single-byte-tail emit uses `w+2 > bound` / `> explim`
  (BHI) — asymmetric shipped comparison operators
- run header: 257-n for n in 2..128
- literal header: n-1 for n in 1..128
