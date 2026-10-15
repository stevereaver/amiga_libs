---
type: Structure
title: InitTable / function table
description: AUTOINIT layout for xpkDLTA 0.2.
---

# InitTable (code+0xb4)

| field | value |
|-------|-------|
| dataSize | 0xfc |
| funcTable | code+0xc4 |
| dataTable | code+0xdc |
| initRoutine | code+0x16a |

# InitStruct data (code+0xdc)

Standard node/library fields first (`ln_Type`=9, `ln_Name`,
`lib_Flags`=6, `lib_Version`=0, `lib_Revision`=2, `lib_IdString`), then
the embedded descriptor fields — XpkMode first (@0x82 xm_Upto=100,
@0x9e/@0xa2 description "ByteMode"), then the XpkInfo block at
base+0x26 (@0x26..@0x5e per [XpkInfo](XpkInfo.md)).  Offset bytes are
flat 8-bit values; offsets up to 0xa2 appear with no extended-offset
encoding.

LibInit (code+0x16a) then stores the seglist at base+0x22 and links
`xi_ModeDesc` (base+0x62) to base+0x7e.

# Function table (code+0xc4)

0xffff marker word, then **signed word offsets from the table base**,
terminated by 0xffff:

| LVO | target | function |
|----:|--------|----------|
| -6  | 0x17a  | LibOpen |
| -12 | 0x188  | LibClose |
| -18 | 0x196  | LibExpunge |
| -24 | 0x20a  | shared null (`moveq #0/rts` inside PackChunk) |
| -30 | 0x216  | XpksPackerInfo |
| -36 | 0x1ce  | XpksPackChunk |
| -42 | 0x20a  | XpksPackFree stub |
| -48 | 0x20a  | XpksPackReset stub |
| -54 | 0x21e  | XpksUnpackChunk |
| -60 | 0x20a  | XpksUnpackFree stub |

# Hunk map

Single CODE hunk, 600 bytes: stub 0x00, RomTag 0x04, strings
0x1e-0xb3, InitTable 0xb4, functab 0xc4, InitStruct data 0xdc-0x169,
code 0x16a-0x255, trailing `nop` 0x256 (rt_EndSkip target, relocated).
17 RELOC32 entries follow in DESCENDING order (toolchain quirk;
`source/fixup.py` reproduces it).
