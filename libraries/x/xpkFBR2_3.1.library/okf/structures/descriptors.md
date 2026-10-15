---
type: Structure
title: Descriptors
---
# Descriptors

## XpkInfo (static, pointers relocated)

ver 1/3/2/0; name "FastByteRun"; longname
"FastBytesRunner for raw Picture/Sound/Data-Files";
desc "Very Fast, better then ByteRun from IFF" (sic);
id 'FBR2'; flags 0x8009; MaxPkInChunk 0x7fffffff;
MinPkInChunk 7; DefPkInChunk 0x7fff; msgs
"Running"/"Running"/"Ready"/"Steady" (Pack and Unpack
share one pointer); DefMode 100 (ByteByte);
ModeDesc -> 4-entry linked list.

## XpkMode list (42 bytes each, linked — order reversed vs V4.1)

| mode | upto | packspeed | unpackspeed | ratio | chunksize | desc |
|------|------|-----------|-------------|-------|-----------|------|
| Autosizing | 0   | 1   | 300  | 0   | 1400 | "Autosizing" |
| LongByte   | 33  | 300 | 1400 | 100 | 0    | "LongByte"   |
| WordByte   | 67  | 300 | 1400 | 100 | 0    | "WordByte"   |
| ByteByte   | 100 | 300 | 1400 | 100 | 0    | "ByteByte"   |

Autosizing has no implementation — mode 0 packs LongByte.
