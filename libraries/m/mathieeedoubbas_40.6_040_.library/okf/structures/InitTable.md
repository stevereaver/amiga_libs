---
type: Structure
title: InitTable / hunk map
description: AUTOINIT table, InitStruct stream and code-hunk layout.
timestamp: 2026-10-10T23:10:00Z
---

# InitTable / hunk map

Single CODE hunk (0x2f0 bytes).  Table order differs from the
FPU build (functab sits before the InitTable here):

| off | contents |
|-----|----------|
| 0x00 | `moveq #0,d0; rts` — loader entry & ExtFunc target |
| 0x04 | RomTag: 0x4afc, AUTOINIT, ver 40, NT_LIBRARY |
| 0x1e | `mathieeedoubbas.library\0` |
| 0x36 | idstring "for 68040" + Berndt credit |
| 0x8a | functab: 16 absolute longwords + -1L |
| 0x9a+~ | InitTable: dataSize 0x2c → datatab 0xce, initFunc 0xf0 |
| 0xce | InitStruct stream (below) |
| 0xf0 | initFunc: store sysbase/seglist, 040/FPU40 gate |
| 0x120+ | Open/Close/Expunge, 12 math vectors (identical to FPU build) |

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
