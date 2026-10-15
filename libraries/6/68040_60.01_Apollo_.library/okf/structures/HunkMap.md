---
type: Structure
title: HunkMap
description: Layout of the single code hunk (0x11c bytes).
---

# Hunk map — 68040.library 60.01 (Apollo)

```
0x000  moveq #0,d0 / rts                 entry for non-resident load
0x004  RomTag  4afc -> rt, endskip 0x11c
       flags 0x80 (AUTOINIT), ver 60, type 9 (NT_LIBRARY), pri 0
       name -> 0x01e  idstr -> 0x031  init -> 0x06c
0x01e  "68040.library\0"
0x02c  "$VER:68o4o/68060.library-loader 60.01 (08 Dec 1995 Z.Urwani)\r\n\0"
       (RT_IDSTRING points at 0x031, i.e. past the "$VER:" prefix)
0x06c  InitTable: dataSize 0x22, funcTable 0x07c, dataTable 0x090,
       initFunc 0x0c0
0x07c  funcTable (absolute longs, -1 terminated):
       Open 0x0b0, Close 0x0b8, Expunge 0x0bc, ExtFunc 0x0bc
0x090  dataTable (old-style InitStruct words):
       a008 0900        ln_Type     = NT_LIBRARY (byte @8)
       800a <libname>   ln_Name     = "68040.library"
       a00e 0600        lib_Flags   = LIBF_CHANGED|LIBF_SUMUSED
       9014 003c        lib_Version = 60
       9016 0000        lib_Revision= 0
       8018 <idstr>     lib_IdString
       0000             terminator
0x0b0  LibOpen: addq.w #1,(32,a6); move.l a6,d0; rts
0x0b8  LibClose: subq.w #1,(32,a6)  -> falls into Expunge
0x0bc  Expunge/ExtFunc: moveq #0,d0; rts
0x0c0  LibInit: AttnFlags checks, OpenLibrary("68o4o.library" /
       "68060.library")
0x0fe  "68o4o.library\0"   (letter 'o', twice)
0x10c  "68060.library\0"
0x11c  ENDSKIP
```

Relocs: 14 × RELOC32 (romtag fields, inittab, functab, two initdata
pointers).
