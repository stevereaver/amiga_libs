---
type: Structure
title: CacheMapBase
description: Private library base allocated by MakeLibrary (dataSize 0x3c).
timestamp: 2026-10-10T19:30:00Z
---

# struct CacheMapBase — 0x3c bytes

| off | field |
|-----|-------|
| 0x00 | `struct Library` (34 bytes; lib_OpenCnt stays 0) |
| 0x22 | `UWORD` private open count |
| 0x24 | `BPTR` seglist |
| 0x28 | `struct ExecBase *` SysBase |
| 0x2c | `struct GfxBase *` GfxBase |
| 0x30 | `struct MinList` node list (12 bytes) |

No InitStruct data table: the init routine writes ln_Name,
lib_IdString, lib_Version(34), lib_Revision(5) itself and opens
`graphics.library` (version 0); failure aborts init (returns 0).
