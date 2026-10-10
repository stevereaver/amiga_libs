---
type: Function
title: XpksPackChunk (LVO -36)
---
# XpksPackChunk

`cmpb` dispatch on the low byte of `xsp_Mode`:

| low byte | path | tag | count | min-run mid/tail | window |
|----------|------|-----|-------|------------------|--------|
| 0..33    | LongByte | 33 | 4B BE | 6/7 extras | inlen   |
| 34..67   | WordByte | 67 | 2B BE | 4/5 extras | 32767   |
| 68..255  | ByteByte | 100| 1B    | 3/4 extras | 127     |

- LongByte: single pass over the whole input; literal
  blocks bounded by `OutBufLen-5` (-17 reject); run
  emits unbounded.  Tail emit: `d6 < 6` folds the seed
  into literals, else `d6++` fixup.
- WordByte/ByteByte: windowed scanner (see
  algorithms/WindowedScan).  No output bound check in
  either path.  Emits OOB memory for inputs smaller
  than the first window (see findings).
- All paths end `outlen = written-1; if <=0 -> -17`,
  else `xsp_OutLen = written`.
- Returns 0 on success, -17 on the expansion guard.
