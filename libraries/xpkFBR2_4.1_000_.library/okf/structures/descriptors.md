---
type: Structure
title: Descriptors
---
# Descriptors

## XpkInfo (hunk+0x35a, static, pointers relocated)

ver 1/4/2/0; name "FastRunner"; longname
"FastBytesRunner V4.0" (stale); desc "Similar to ByteRun
from IFF"; id 'FBR2'; flags 0x8009; MaxPkInChunk
0x7fffffff; DefPkInChunk 0x8000; msgs
"Running"/"Running"/"Ready"/"Steady"; DefMode 90;
ModeDesc -> mode chain.

## XpkMode chain (hunk+0x3b2, inline 10-byte descs)

| upto | desc | packspeed | unpackspeed | ratio |
|------|------|-----------|-------------|-------|
| 33 | LongByte | 290 | 1150 | 36 |
| 67 | WordByte | 290 | 950 | 44 |
| 90 | ByteByte | 290 | 1150 | 48 |
| 100 | AutoSize | 100 | 1050 | 49 |

## FbrBase (dataSize 0x26)

struct Library + seglist at +0x22.
