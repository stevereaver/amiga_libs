---
type: Function
title: XpksUnpackChunk (LVO -54)
---
# XpksUnpackChunk

RLE decoder.  `a0` = XpkSubParams; `a6` = base (unused).

- insize 0 -> OutLen=0, return 0
- insize >= 0xfffc -> -11
- per-byte output bound `dst+0x100+OutBufLen` -> -10
- h < 0x80: literal h+1; h >= 0x80: repeat byte 257-h
- writes OutLen on success; no terminator byte
