---
type: Structure
title: InitTable
description: AUTOINIT tables and InitStruct stream.
---

# InitTable / InitStruct

RomTag: RTF_AUTOINIT (0x80), RT_VERSION 1, NT_LIBRARY,
pri 0, RT_ENDSKIP at hunk end.

InitTable: dataSize 0xaa, functab = word-offset table
(-1 marker + 10 entries + -1), datatab, initFunc.

InitStruct stream:

```
a008 0900        INITBYTE  ln_Type = 9 (NT_LIBRARY)
800a <name>      INITLONG  ln_Name = "xpkCBR0.library"
a00e 0600        INITBYTE  lib_Flags = 6
9014 0001        INITWORD  lib_Version = 1
9016 0001        INITWORD  lib_Revision = 1
8018 <idstr>     INITLONG  lib_IdString = "xpkCBR0 v1.1"
0000             terminator
```
