---
type: Structure
title: InitTable
description: Module header tables.
timestamp: 2026-10-10T20:20:00Z
---

# Module layout (single CODE hunk, 0x364 bytes)

- 0x00 `moveq #-1,d0 / rts` entry
- 0x04 RomTag: RTF_AUTOINIT, ver 1, type 9, pri 0, endskip 0x361
- 0x1e `ted.library`, 0x2a `ted 1.0 (28.12.95)\r\n`,
  0x3f `dos.library`
- 0x4c InitTable `{0x30, functab@0x5c, datatab@0xb0, init@0xd0}`
- 0x5c functab: 20 absolute vectors + -1L
- 0xb0 InitStruct data: NT_LIBRARY, name, flags 6,
  version 1, revision 0, idstring
- 0x24e..0x261: five global longs; 0x262..0x360: 255-byte buffer
