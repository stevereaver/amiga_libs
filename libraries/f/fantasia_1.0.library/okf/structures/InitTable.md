---
type: Structure
title: InitTable
description: RomTag, InitTable and InitStruct contents.
timestamp: 2026-10-10T18:00:00Z
---

# InitTable / RomTag

RomTag at code+0x04: EndSkip→0x52 — equal to RT_INIT (points at the
InitTable itself, mid-module: quirk, cf. fwfiltertype whose EndSkip
points at its init routine).  Flags 0x80 AUTOINIT, version 1,
NT_LIBRARY, pri 0.  Name `"fantasia.library"`, id
`"fantasia.library 1.0\n"`.

InitTable: dataSize 0x30, funcTable→0x62 (**absolute longs**),
dataTable→0x7c, initFunc→0x9a.

InitStruct: `INITBYTE(0x0c,9)` (quirk — writes inside ln_Name, dead),
INITLONG(0x0a) name, INITBYTE(0x0e,6), INITWORD(0x14,1),
INITWORD(0x16,0), INITLONG(0x18) idstring.

Function table: `dc.l` Open, Close, Expunge, Reserved, JoyDir
(0x138), JoyButtons (0x20c); `dc.l -1`.
