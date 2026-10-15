---
type: Structure
title: InitTable
description: AUTOINIT init table and the absolute-long function table format.
timestamp: 2026-10-10T19:00:00Z
---

# InitTable / function table

The RomTag has `RTF_AUTOINIT` (rt_Flags=0x80, rt_Version=37,
rt_Type=9 NT_LIBRARY, rt_Pri=0).  `rt_Init` points at the standard
four-field init table:

```
dc.l   0x2c          | dataSize = sizeof(VersionBase)
dc.l   _functab      | function table
dc.l   _datatab      | InitStruct data
dc.l   LibInit       | init vector (d0=base, a0=seglist, a6=SysBase)
```

The function table is an array of **absolute longword addresses**
terminated by `-1L`:

```
dc.l   LibOpen       | LVO -6
dc.l   LibClose      | LVO -12
dc.l   LibExpunge    | LVO -18
dc.l   LibNull       | LVO -24 (reserved/ExtFunc)
dc.l   -1
```

MakeLibrary distinguishes the two table formats by the first word:
`-1` means a word-offset table (offsets relative to the table start,
data beginning after the marker word); anything else means absolute
long pointers.  These binaries use the absolute form (first word is
0x0000).

InitStruct data uses the compact command encoding.
