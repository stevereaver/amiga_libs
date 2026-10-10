---
type: Structure
title: InitTable
description: RomTag, InitTable and InitStruct contents.
timestamp: 2026-10-10T18:00:00Z
---

# InitTable / RomTag

RomTag at code+0x04: EndSkip→0x200 (hunk end), flags 0x80
RTF_AUTOINIT, version 1, NT_LIBRARY, pri 0, name
`"boards.library"`, id `"boards.library 1.0 (14.4.96)\r\n"`,
init→0xd0.

InitTable: dataSize 0x2c, funcTable→0xe0 (**absolute longs**),
dataTable→0xf8, initFunc→0x118.

InitStruct (code+0xf8): INITBYTE(0x08,9) ln_Type, INITLONG(0x0a)
name, INITBYTE(0x0e,6) flags, INITWORD(0x14,1) version,
INITWORD(0x16,0) revision, INITLONG(0x18) idstring.

Function table: `dc.l` Open 0x162, Close 0x170, Expunge 0x184,
Reserved 0x1de, BoardsFunc 0x1e2; `dc.l -1` terminator.
