---
type: Structure
title: WBStartBase
description: Private library base allocated by MakeLibrary (dataSize 0x38).
timestamp: 2026-10-10T20:00:00Z
---

# struct WBStartBase — 0x38 bytes

| off | field |
|-----|-------|
| 0x00 | `struct Library` (34 bytes; init writes lib_Revision=2) |
| 0x24 | `BPTR` seglist |
| 0x28 | `struct ExecBase *` SysBase |
| 0x2c | `struct Library *` workbench.library v45 |
| 0x30 | `struct Library *` utility.library v40 |
| 0x34 | `struct Library *` dos.library v40 |

InitStruct data table is NULL: exec's InitResident copies
rt_Name/rt_IdString/rt_Version into the public Library fields;
the init routine only sets lib_Revision = 2 and opens the three
support libraries.
