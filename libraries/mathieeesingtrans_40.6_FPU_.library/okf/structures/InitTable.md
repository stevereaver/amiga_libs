---
type: Structure
title: InitTable / hunk map
description: AUTOINIT table, InitStruct stream and code-hunk layout.
timestamp: 2026-10-10T22:30:00Z
---

# InitTable / hunk map

Single CODE hunk (0x280 bytes).  Offsets from hunk start:

| off  | contents |
|------|----------|
| 0x00 | `moveq #0,d0; rts` — loader entry, also IEEESPPow's error exit and the ExtFunc target |
| 0x04 | RomTag: 0x4afc, RTF_AUTOINIT, ver 40, NT_LIBRARY, pri 0 |
| 0x1e | `mathieeesingtrans.library\0` |
| 0x38 | idstring (ends `Berndt\0`, no trailing CRLF) |
| 0x82 | InitTable: dataSize 0x2c, functab→0x92, datatab→0xea, initFunc→0x10c |
| 0x92 | functab: 21 absolute longwords + -1L |
| 0xea | InitStruct stream (below) |
| 0x10c | initFunc: store sysbase/seglist, AttnFlags gate |
| 0x134 | Open / 0x144 Close / 0x154 Expunge+tail |
| 0x194 | 17 math stubs; Pow routine at 0x210 with its core at 0x25c |

## InitStruct stream

```
a0 08 09 00    INITBYTE  ln_Type      = 9 (NT_LIBRARY)
80 0a <name>   INITLONG  ln_Name      = libname (relocated)
a0 0e 06 00    INITBYTE  lib_Flags    = 0x06
90 14 0028     INITWORD  lib_Version  = 40
90 16 0006     INITWORD  lib_Revision = 6
80 18 <idstr>  INITLONG  lib_IdString = idstr (relocated)
00 00          end
```

The longword pointers (ln_Name, lib_IdString, the functab
entries, RomTag fields) make up most of the 31-entry RELOC32
table at the hunk trailer.
