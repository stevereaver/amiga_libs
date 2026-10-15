---
type: Structure
title: InitTable
description: RomTag, InitTable and InitStruct contents.
timestamp: 2026-10-10T18:00:00Z
---

# InitTable / RomTag

RomTag at code+0x04: EndSkip→0x164 (hunk end), flags 0x80
RTF_AUTOINIT, version 40, NT_LIBRARY, pri 0, name
`"_asl.library"`, id `"$VER: _asl.library 40.6"`, init→0x44.

InitTable: dataSize 0x2e, funcTable→0x54, dataTable→0x6e,
initFunc→0x94.

InitStruct (code+0x6e):

| op | field | value |
|----|-------|-------|
| INITBYTE(0x0c) | libbase+0x0c | 9 — quirk: writes inside the ln_Name pointer, overwritten by the next op |
| INITLONG(0x0a) | ln_Name | "_asl.library" |
| INITBYTE(0x0e) | lib_Flags | 6 = LIBF_CHANGED\|LIBF_SUMUSED |
| INITWORD(0x14) | lib_Version | 40 |
| INITWORD(0x16) | lib_Revision | 6 |
| INITLONG(0x18) | lib_IdString | "$VER: _asl.library 40.6" |
| INITLONG(0x26) | sh_RealName | `_libname+1` = "asl.library" |

Function table: `-1`, then 0x0050 0x0060 0x0076 0x00b4 0x00b8
0x00bc 0x00c0 0x00c4 0x00c8 0x00cc (→ Open/Close/Expunge/stub/
six relays), `-1`, plus a second `-1` pad word at 0x6c.
