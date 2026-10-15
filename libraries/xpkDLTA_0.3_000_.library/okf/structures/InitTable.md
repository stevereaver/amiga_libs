---
type: Structure
title: InitTable / function table
description: AUTOINIT layout for xpkDLTA 0.3(000).
---

# InitTable (code+0x64)

| field | value |
|-------|-------|
| dataSize | 0x26 |
| funcTable | code+0x94 |
| dataTable | code+0x74 |
| initRoutine | code+0xac |

# InitStruct data (code+0x74)

```
INITBYTE @08 = 9        ln_Type = NT_LIBRARY
INITLONG @0a = name     "xpkDLTA.library"
INITBYTE @0e = 6        lib_Flags = LIBF_SUMUSED|LIBF_CHANGED
INITWORD @14 = 0        lib_Version
INITWORD @16 = 3        lib_Revision
INITLONG @18 = idstr    "$VER: xpkDLTA V0.3 (1 Oct 2013) ..."
```

# Function table (code+0x94)

0xffff marker word, then **signed word offsets from the table base**,
terminated by 0xffff.  Empty slots encode `0xff6c` = offset -0x94 =
the `moveq #0,d0/rts` stub at code+0:

| LVO | target | function |
|----:|--------|----------|
| -6  | 0xb4   | LibOpen |
| -12 | 0xc2   | LibClose |
| -18 | 0xd4   | LibExpunge |
| -24 | 0x00   | stub |
| -30 | 0x112  | XpksPackerInfo |
| -36 | 0x11a  | XpksPackChunk |
| -42 | 0x00   | XpksPackFree stub |
| -48 | 0x00   | XpksPackReset stub |
| -54 | 0x140  | XpksUnpackChunk |
| -60 | 0x00   | XpksUnpackFree stub |

# Hunk map

Single CODE hunk, 600 bytes: stub 0x00, RomTag 0x04, strings
0x1e-0x63, InitTable 0x64, InitStruct 0x74, functab 0x94, code
0xac-0x159, XpkInfo 0x15a, XpkMode 0x1b2, string pool 0x1dc-0x256,
pad to 0x258.  17 ascending RELOC32 entries follow; no EndSkip reloc.
