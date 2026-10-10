---
type: Algorithm
title: FBR2 stream format
---
# FBR2 stream format

`<tag>` then repeated `<signed count><payload>` items;
decoding stops at input exhaustion.

| tag | count field | encoder min-run | piece cap |
|-----|-------------|-----------------|-----------|
| 33  | 4-byte BE   | 8               | inlen     |
| 67  | 2-byte BE   | 5               | 0x8000    |
| 90* | 1-byte      | 3               | 0x80      |

*ByteByte: encoder emits tag 90, decoder accepts 100 —
see findings.

- count >= 0: repeat the next byte count+1 times (count=0
  is a 1-byte run, equivalent to literal-1)
- count < 0: copy 1-count literal bytes
- runs and literals are emitted in <=cap pieces; larger
  runs/literals split into multiple items
- encoder bound: -17 when the write cursor reaches
  dst+inlen (expansion guard, checked after data-byte
  writes only — count bytes are unbounded)

Decoder accepts tags 100/67/33 only; no output bound
check; never writes xsp_OutLen.
