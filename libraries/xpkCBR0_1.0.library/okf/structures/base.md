---
type: Structure
title: XpkSubBase (dataSize 0xaa)
---
# XpkSubBase

| off | contents |
|-----|----------|
| +0x00 | struct Library |
| +0x22 | pad |
| +0x24 | seglist (LibInit) |
| +0x28 | XpkInfo, 0x58 bytes (runtime-filled) |
| +0x80 | XpkMode, 0x2a bytes (runtime-filled) |

XpkInfo fields (shipped values): ver 1/1/1/0, name "CBR0",
longname "Cmp Byte Run 0 Packer V1.0", id 'CBR0', flags 9
(chunk pack+unpack), MaxPkInChunk 0xfffc, MinPkInChunk 0,
DefPkInChunk 0xfffc, DefMode 50, ModeDesc -> base+0x80.

XpkMode fields: Upto 100, Flags 1 (XPKMF_A3000SPEED),
PackSpeed 410, UnpackSpeed 1918, Ratio 31, ChunkSize 63,
Description "normal".
