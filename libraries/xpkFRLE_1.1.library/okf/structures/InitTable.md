---
type: Structure
title: InitTable / hunk map
description: AUTOINIT table, InitStruct stream and code-hunk layout.
timestamp: 2026-10-10T22:45:00Z
---

# InitTable / hunk map

Single CODE hunk (0x2f8 bytes).  Offsets from hunk start:

| off  | contents |
|------|----------|
| 0x00 | `moveq #-1,d0; rts` — loader entry (returns -1, quirk) |
| 0x04 | RomTag: 0x4afc, AUTOINIT, ver 1, NT_LIBRARY, pri 0, ENDSKIP = hunk end |
| 0x1e | InitTable: dataSize 0x26, functab→0x2e, datatab→0x46, initFunc→0x15e |
| 0x2e | functab: -1 marker, 10 word offsets, -1 terminator |
| 0x46 | InitStruct stream (below) |
| 0x66 | XpkInfo (88 B), XpkMode (42 B) |
| 0xe8 | "xpkFRLE.library\0" |
| 0xf8 | "xpkFRLE v1.1\r\n\0" — no $VER: cookie |
| 0x107+ | "FRLE", longname, description, message strings |
| 0x15e | initFunc: `movea.l d0,a1; move.l a0,34(a1); rts` (stores seglist) |
| 0x166 | Open / 0x174 Close / 0x182 Expunge |
| 0x1b8 | null stub `moveq #0,d0; rts` (ExtFunc, PackFree, PackReset, UnpackFree) |
| 0x1bc | XpksPackerInfo: `lea xpkinfo(pc),a0` |
| 0x1c4 | XpksPackChunk encoder / 0x2a4 decoder |

## InitStruct stream

```
a0 08 09 00    INITBYTE  ln_Type      = 9 (NT_LIBRARY)
80 0a <name>   INITLONG  ln_Name      = libname
a0 0e 06 00    INITBYTE  lib_Flags    = 0x06
90 14 0001     INITWORD  lib_Version  = 1
90 16 0001     INITWORD  lib_Revision = 1
80 18 <idstr>  INITLONG  lib_IdString = idstr
00 00          end
```
