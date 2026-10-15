# XpksPackChunk (-36)

PackBits RLE encoder (params via `struct XpkSubParams` a0, base a6).

- run detection: 3 equal bytes ahead starts a repeat run
- literal runs emit `+count` (<=127) then the bytes
- repeat runs emit `-count` then the value byte
- overflow check `out + pending + 4 > outlim` -> XPKERR_EXPANSION(-17)
- terminator byte 0; xsp_OutLen set; returns 0
