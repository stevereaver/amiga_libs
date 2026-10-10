---
type: Structure
title: AUTOINIT / vector table
description: RomTag, MakeLibrary init array and the 24-entry function table.
---

# AUTOINIT & vector table

RomTag at hunk0 offset 4: `RTC_MATCHWORD`, self MatchTag, EndSkip, flags
`0x80`=RTF_AUTOINIT, version 3, type `NT_LIBRARY`, pri 0, name "zlib.library",
id `"$VER: zlib.library 3.2 (11-Apr-03)"`, init → AUTOINIT array.

AUTOINIT array: `{dataSize=0x22, FUNCTABLE, DATATABLE, INITFUNCTION}`.

DATATABLE (MakeLibrary init table) decodes to:

| Field | Value |
|-------|-------|
| ln_Type (8) | 9 = NT_LIBRARY |
| ln_Name (10) | "zlib.library" |
| lib_Flags (14) | 6 = LIBF_SUMUSED\|LIBF_CHANGED |
| lib_Version (20) | 3 |
| lib_Revision (22) | 2 |
| lib_IdString (24) | "$VER: zlib.library 3.2 (11-Apr-03)" |

Opcode words `0x8000`=INITLONG / `0x9000`=INITWORD / `0xa000`=INITBYTE differ
from the NDK macros (`0xc000/0xd000/0xe000`) — StormC emits its own flavour;
exec's InitStruct accepts both encodings (values land correctly, lib works).

FUNCTABLE (hunk3): 24 `DC.L` + `$ffffffff` terminator; relocs split entries
between hunk0 (m68k) and hunk1 (PPC) — see [HunkMap](HunkMap.md).
