---
type: Structure
title: InitTable
description: RomTag, InitTable and InitStruct contents.
timestamp: 2026-10-10T18:00:00Z
---

# InitTable / RomTag

RomTag at code+0x04: MatchTag→self, EndSkip→0x130 (end of hunk),
flags 0x81 = RTF_AUTOINIT|RTF_COLDSTART, version 40, NT_LIBRARY,
pri 0, name `"freeanim.library"`, id `"freeanim.library 40.9
(11.8.95)\r\n"`, init→0x54.

InitTable (code+0x54): dataSize 0x26, funcTable→0x64,
dataTable→0x70, initFunc→0x128.

InitStruct (code+0x70, standard exec initializers encoding):

| op | field | value |
|----|-------|-------|
| INITBYTE(0x08) | ln_Type | 9 (NT_LIBRARY) |
| INITLONG(0x0a) | ln_Name | "freeanim.library" |
| INITBYTE(0x0e) | lib_Flags | 6 = LIBF_CHANGED\|LIBF_SUMUSED |
| INITWORD(0x14) | lib_Version | 40 |
| INITWORD(0x16) | lib_Revision | 9 |
| INITLONG(0x18) | lib_IdString | id string |

Function table at 0x64: `-1`, entries `0x008c 0x0094 0x0030 0x002c`
→ Open 0xf0, Close 0xf8, Expunge 0x94, stub 0x90; `-1`.
