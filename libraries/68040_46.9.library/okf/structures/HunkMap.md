---
type: Structure
title: HunkMap
description: Layout of the single code hunk (0x1cc bytes).
---

# Hunk map — 68040.library 46.9 (Lynxx)

```
0x000  moveq #0,d0 / rts                 entry for non-resident load
0x004  RomTag  4afc -> rt, endskip 0x1ca
       flags 0x80 (AUTOINIT), ver 46, type 9, pri 0
       name -> 0x01e  idstr -> 0x056  init -> 0x0a0
0x01e  "68040.library\0"
0x02c  "68060.library\0"          (opened at +2 → "060.library")
0x03a  "Libs:68040mmu.library\0"  (LoadSeg'd at +2 → "bs:68040mmu…")
0x050  "$VER: 040/060-Loader.library 46.9 (21.11.2020) by Holger
        'Lynxx' Hippenstiel.\n\0"  (RT_IDSTRING points at 0x56)
0x0a0  InitTable: dataSize 0x34, funcTable 0x0b0, dataTable 0x0c4,
       initFunc 0x0ea
0x0b0  funcTable (absolute longs, -1 terminated):
       Open 0x1ac, Close 0x1c6, Expunge 0x1c6, ExtFunc 0x1c6
0x0c4  dataTable (old-style InitStruct words):
       a008 0900        ln_Type      = NT_LIBRARY
       800a <libname>   ln_Name
       a00e 0600        lib_Flags    = CHANGED|SUMUSED
       9014 002e        lib_Version  = 46
       9016 0009        lib_Revision = 9
       8018 <idstr>     lib_IdString
       8030 0000 0000   lb_OpenLib   = NULL
       0000             terminator
0x0ea  LibInit
0x13c  LoadAndResident: LoadSeg / RomTag scan / InitResident(d0 quirk)
0x188  ProbeBody: movec vbr; patch vector 4; movec pcr (0x808); rte
0x1ac  LibOpen
0x1c6  LibClose/Expunge/ExtFunc: moveq #0,d0; rts
0x1ca  ENDSKIP (last word is a 0 pad inside the hunk)
```

Relocs: 15 × RELOC32.
