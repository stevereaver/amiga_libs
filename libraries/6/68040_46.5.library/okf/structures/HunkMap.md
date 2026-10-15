---
type: Structure
title: HunkMap
description: Layout of the single code hunk (0x2a0 bytes).
---

# Hunk map — 68040.library 46.5 (Phase5)

```
0x000  moveq #0,d0 / rts                 entry for non-resident load
0x004  RomTag  4afc -> rt, endskip 0x2a0
       flags 0x80 (AUTOINIT), ver 46, type 9, pri 0
       name -> 0x01e  idstr -> 0x02c  init -> 0x0d4
0x01e  "68040.library\0"
0x02c  "68040.library 46.5 (19.10.99) © 1994-1999 by Phase5,
        written by Ralph Schmidt\r\n\0"
0x07e  "$VER: 68040.library 46.5 (19.10.99) © 1994-1999 by Phase5,
        written by Ralph Schmidt\0"   (duplicate, no CRLF)
0x0d4  InitTable: dataSize 0x38, funcTable 0x0e4, dataTable 0x0f8,
       initFunc 0x15e
0x0e4  funcTable (absolute longs, -1 terminated):
       Open 0x278, Close 0x292, Expunge 0x296, ExtFunc 0x29a
0x0f8  dataTable (old-style InitStruct words):
       a008 0900        ln_Type      = NT_LIBRARY
       800a <libname>   ln_Name
       a00e 0600        lib_Flags    = CHANGED|SUMUSED
       9014 002e        lib_Version  = 46
       9016 0005        lib_Revision = 5
       8018 <idstr>     lib_IdString
       802c 0000 0000   pb_LoadLib   = NULL
       8028 0000 0000   pb_OpenLib   = NULL
       0000             terminator
0x124  Probe040 wrapper (movea 4.w → SysBase, jsr -30 Supervisor)
0x138  probe body: movec vbr; patch vec 4; movec pcr (4e7a 9808); rte
0x15e  LibInit
0x1cc  "LIBS:68060.library\0"   (opened at +5 → "68060.library")
0x1df  "LIBS:68040old.library\0" (helper called at +5, -5 inside)
0x1f5  "LIBS:68040new.library\0"
0x20b  "dos.library\0"
0x218  FindRomTag: seglist scan for 4afc self-referencing tag
0x242  LoadAndInit: LoadSeg / UnLoadSeg / InitResident(d0 quirk)
0x278  LibOpen
0x292  LibClose / 0x296 LibExpunge / 0x29a LibNull (three stubs)
0x29e  nop pad
0x2a0  ENDSKIP
```

Relocs: 14 × RELOC32.
