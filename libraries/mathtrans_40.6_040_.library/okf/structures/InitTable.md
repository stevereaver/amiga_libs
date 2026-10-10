---
type: Structure
title: InitTable
description: AUTOINIT tables and InitStruct stream.
---

# InitTable / InitStruct

Resident module: `moveq #0,rts` entry, RomTag with
RTF_AUTOINIT (0x80), RT_VERSION 40, NT_LIBRARY, pri 0,
RT_ENDSKIP pointing at the InitTable itself (hunk+0x6e).

InitTable: dataSize 0x2c, absolute-longword functab
(21 entries + -1L terminator), InitStruct datatab, initFunc.

InitStruct stream:

```
a008 0900        INITBYTE  ln_Type(0x08)   = 9 (NT_LIBRARY)
800a <name>      INITLONG  ln_Name(0x0a)   = "mathtrans.library"
a00e 0600        INITBYTE  lib_Flags(0x0e) = 0x06
9014 0028        INITWORD  lib_Version     = 40
9016 0006        INITWORD  lib_Revision    = 6
8018 <idstr>     INITLONG  lib_IdString    = idstr
0000             terminator
```

initFunc: clears OpenCnt, stores SysBase (+0x22) and seglist
(+0x26), requires AFF_68040; for exec V39+ it also requires
AFF_FPU40 (the 68040-FPU attention bit, checked via
`btst #6` — the build still needs the FPSP-visible flag
even though all transcendental work is done in software;
`fsqrts`/`fint`-adjacent ops are used directly).
