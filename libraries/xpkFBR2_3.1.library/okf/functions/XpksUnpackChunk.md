---
type: Function
title: XpksUnpackChunk (LVO -54)
---
# XpksUnpackChunk

Reads the tag byte, then loops `while src < inbuf+inlen-1`
reading signed counts:

- tag 100: `moveb`-sized counts
- tag 67: 2-byte BE counts
- tag 33: 4-byte BE counts
- else: return -12

count >= 0 -> copy next byte count+1 times to output;
count < 0 -> copy 1-count input bytes to output.

Shipped semantics kept:

- no bound check on the write cursor — corrupt streams
  overrun OutBuf arbitrarily
- never writes `xsp_OutLen`
- count read at src=end-1 overreads past InLen
- returns 0 even for a zero-length body
