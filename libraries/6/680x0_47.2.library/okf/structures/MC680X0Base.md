---
type: Structure
title: MC680X0Base (library base)
description: Private library base layout, 0x40 bytes.
resource: source/680x0.c
timestamp: 2026-10-10T18:00:00Z
---

# MC680X0Base

InitTable `dataSize` is 0x40: `struct Library` (34 bytes) + private
fields.  Field offsets recovered from the LibInit stores:

| offset | field | evidence |
|-------:|-------|----------|
| 0x00 | `struct Library b_Lib` | fields filled by hand in LibInit |
| 0x22 | `UWORD` pad | alignment gap, never accessed |
| 0x24 | `ULONG b_Magic` | `movel #'THOR',a5@(36)` - literal 'THOR' |
| 0x28 | `ULONG` pad | unused |
| 0x2c | `BPTR b_SegList` | `movel a0,a5@(44)` (a0 = seglist at init) |
| 0x30 | `ULONG` pad | unused |
| 0x34 | `ULONG` pad | unused |
| 0x38 | `struct ExecBase *b_SysBase` | `movel a6,a5@(56)`; read everywhere |
| 0x3c | `UBYTE b_CPUType` | `moveb d2,a5@(60)` - ASCII CPU digit |
| 0x3d | `UBYTE[3]` pad | to 0x40 |

LibInit writes ln_Type (NT_LIBRARY), lib_Flags
(LIBF_SUMUSED|LIBF_CHANGED), ln_Name, lib_IdString, lib_Version/
lib_Revision and b_Magic itself - the InitTable carries no
InitStruct data (third field is 0).
