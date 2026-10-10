---
type: Structure
title: InitTable / hunk map
description: AUTOINIT table, InitStruct stream and code-hunk layout.
timestamp: 2026-10-10T23:00:00Z
---

# InitTable / hunk map

Single CODE hunk (0x2e4 bytes).  Layout mirrors the 40.6
singtrans build:

| off | contents |
|-----|----------|
| 0x00 | `moveq #0,d0; rts` — loader entry & ExtFunc target |
| 0x04 | RomTag: 0x4afc, AUTOINIT, ver 40, NT_LIBRARY |
| ~0x1e | `mathieeedoubbas.library\0` |
| ~0x36 | idstring (Berndt credit, no trailing CRLF) |
| ~0x8a | InitTable: dataSize 0x2c, functab, datatab, initFunc |
| functab | 16 absolute longwords + -1L |
| datatab | InitStruct stream (below) |
| code | initFunc, Open/Close/Expunge, 12 math vectors |

## InitStruct stream

```
a0 08 09 00    INITBYTE  ln_Type      = 9 (NT_LIBRARY)
80 0a <name>   INITLONG  ln_Name      = libname
a0 0e 06 00    INITBYTE  lib_Flags    = 0x06
90 14 0028     INITWORD  lib_Version  = 40
90 16 0006     INITWORD  lib_Revision = 6
80 18 <idstr>  INITLONG  lib_IdString = idstr
00 00          end
```
