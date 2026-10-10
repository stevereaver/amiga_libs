---
type: Structure
title: RomTag / InitTable / hunk map
description: RomTag fields, AUTOINIT table and hunk layout.
timestamp: 2026-10-10T18:00:00Z
---

# RomTag / InitTable / hunk map

Code hunk starts with `moveq #-1,d0 / rts` (the executable entry for
non-resident loaders).  RomTag at text+0x04:

- rt_MatchTag -> itself, **rt_EndSkip = 0** (stored literal, no
  relocation - not a pointer to the entry code)
- rt_Flags 0x80 (RTF_AUTOINIT), rt_Version 47, rt_Type 9
  (NT_LIBRARY), rt_Pri 0
- rt_Name/rt_IdString -> .data strings, rt_Init -> InitTable at .data+0

## InitTable (.data+0x00)

```
dc.l 0x40        ; dataSize = sizeof(struct MC680X0Base)
dc.l functab     ; -> .data+0x10
dc.l 0           ; no InitStruct data
dc.l LibInit     ; -> .text init routine
```

## Function table (.data+0x10)

Absolute longword pointers (first word is 0, so exec uses the
pointer interpretation), -1L terminated, 8 entries:

- Open, Close, Expunge, ExtFunc(=returns 0)
- CPUType(-30), FPUType(-36), MMUType(-42), SetFPUExceptions(-48)

## Strings (.data+0x34)

`"680x0.library"`, `"mmu.library"`, `"$VER: "` prefix immediately
followed by the id string (`"680x0.library 47.2 (19.3.2022) (c) 1999-2017 The
MMU.lib development group, THOR"`, \n\r\0).  lib_IdString points
*after* the `"$VER: "` cookie; the version scanner still finds the
standard sequence because the bytes are adjacent.
Note: the 47.2 data hunk additionally contains an `apollo.library`
string (0x42) that no code references - dead data, reproduced in
`source/680x0_lib.s`.

