---
type: Function
title: XpksUnpackChunk (LVO -54)
---
# XpksUnpackChunk

`moveml a0@,a0-a2` loads inbuf/inlen/outbuf; reads tag:

- 100: 1-byte signed counts
- 67:  2-byte signed counts
- 33:  4-byte signed counts
- else: -12 (bad tag)

count >= 0: repeat next byte count+1; count < 0: copy
1-count literals. Stops at input exhaustion; writes NO
output bound check and NO xsp_OutLen.
