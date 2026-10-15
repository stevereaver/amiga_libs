---
type: Algorithm
title: FBR2 stream format (V3.1)
---
# FBR2 stream format (V3.1)

`<tag>` then repeated `<signed count><payload>` items;
decoding stops when `src >= inbuf+inlen-1`.

| tag | mode | count field | encoder min-run (mid/tail) | window |
|-----|------|-------------|----------------------------|--------|
| 33  | <=33 | 4-byte BE   | 6 / 7 extras               | inlen  |
| 67  | <=67 | 2-byte BE   | 4 / 5 extras               | 32767  |
| 100 | else | 1-byte      | 3 / 4 extras               | 127    |

- count >= 0: repeat the next byte count+1 times (count=0
  is a 1-byte run, equivalent to literal-1)
- count < 0: copy 1-count literal bytes
- LongByte bounds each literal block against
  OutBufLen-5 (-17 on overflow); run items and both
  W/B paths write without any output check.
- xsp_Mode is compared as a BYTE — only the low byte
  matters (mode 0x121 packs LongByte).
- No AutoSize pass; "Autosizing" (mode 0) packs LongByte.

Decoder accepts tags 100/67/33 only; a count field at
src == inbuf+inlen-1 is never read (loop guard
`src < end-1`); no output bound check; never writes
xsp_OutLen.
