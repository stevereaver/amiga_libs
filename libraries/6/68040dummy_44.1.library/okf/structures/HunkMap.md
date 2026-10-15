---
type: Structure
title: HunkMap
description: Layout of the single code hunk (0x268 bytes).
---

# Hunk map — 68040.library 44.1 (Phase5 dummy)

```
0x000  moveq #0,d0 / rts                 entry for non-resident load
0x004  RomTag  4afc -> rt, endskip 0x268
       flags 0x80 (AUTOINIT), ver 44, type 9, pri 0
       name -> 0x01e  idstr -> 0x02c  init -> 0x0d0
0x01e  "68040.library\0"
0x02c  "68040.library 44.1 (21.6.98) © 1994-1998 by Phase5,
        written by Ralph Schmidt\r\n\0"
0x07d  "$VER: 68040.library 44.1 (21.6.98) © 1994-1998 by Phase5,
        written by Ralph Schmidt\0"   (duplicate, no CRLF)
0x0d0  InitTable: dataSize 0x38, funcTable 0x0e0, dataTable 0x0f4,
       initFunc 0x120
0x0e0  funcTable (absolute longs, -1 terminated):
       Open 0x240, Close 0x25a, Expunge 0x25e, ExtFunc 0x262
0x0f4  dataTable (old-style InitStruct words):
       a008 0900        ln_Type      = NT_LIBRARY
       800a <libname>   ln_Name
       a00e 0600        lib_Flags    = CHANGED|SUMUSED
       9014 002c        lib_Version  = 44
       9016 0001        lib_Revision = 1
       8018 <idstr>     lib_IdString
       802c 0000 0000   pb_LoadLib   = NULL
       8028 0000 0000   pb_OpenLib   = NULL
       0000             terminator
0x120  LibInit (dispatch on AttnFlags bits 7/3/6)
0x194  "LIBS:68060.library\0"   opened at +7 → "060.library"
0x1a8  "LIBS:68040old.library\0"  (helper called at +5, -5 inside)
0x1be  "LIBS:68040new.library\0"
0x1d4  "dos.library\0"
0x1e0  FindRomTag: seglist scan for 4afc self-referencing tag
0x20a  LoadAndInit: LoadSeg / UnLoadSeg / InitResident(d0 quirk)
0x240  LibOpen
0x25a  LibClose / 0x25e LibExpunge / 0x262 LibNull (three stubs)
0x266  nop pad
0x268  ENDSKIP
```

Relocs: 14 × RELOC32.
