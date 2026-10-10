---
type: Structure
title: InitTable
description: AUTOINIT table; word-offset function table with -1 marker.
resource: source/xpkNONE_lib.s
timestamp: 2026-10-10T09:20:00Z
---

# InitTable

Conventional layout this time: RomTag at .text+0x04 (immediately after
the entry stub), InitTable at .text+0x62, InitStruct data at .text+0x72,
function table at .text+0x92.

```
dc.l   0x26          | dataSize = sizeof(XpkSubBase)
dc.l   FUNCTABLE     | .text+0x92
dc.l   DATATABLE     | .text+0x72
dc.l   INITFUNCTION  | .text+0xaa
```

RomTag fields: `RTF_AUTOINIT`, version 1, NT_LIBRARY, pri 0,
name .text+0x1e, idstring .text+0x2e (with `$VER:` cookie),
RT_ENDSKIP = .text+0x00 (the entry stub).

## Function table — word-offset format

12 words at .text+0x92: a leading `-1` marker selects the
offset-relative table format, then 10 word offsets *relative to the
table base* (0x92), terminated by `-1`:

| LVO | word | target |
|----:|------|--------|
| -6  | 0x0020 | LibOpen .text+0xb2 |
| -12 | 0x002e | LibClose .text+0xc0 |
| -18 | 0x0040 | LibExpunge .text+0xd2 |
| -24 | 0xff6e | .text+0x00 (entry stub, returns 0) |
| -30 | 0x007e | XpksPackerInfo .text+0x110 |
| -36 | 0x0086 | XpksPackChunk .text+0x118 |
| -42 | 0xff6e | .text+0x00 |
| -48 | 0xff6e | .text+0x00 |
| -54 | 0x008a | XpksUnpackChunk .text+0x11c |
| -60 | 0xff6e | .text+0x00 |

## InitStruct data (compact byte-offset commands at .text+0x72)

| command | field | value |
|---------|-------|-------|
| `a0 08` | INITBYTE ln_Type @8 | 9 (NT_LIBRARY) |
| `80 0a` | INITLONG ln_Name @10 | "xpkNONE.library" |
| `a0 0e` | INITBYTE lib_Flags @14 | 6 |
| `90 14` | INITWORD lib_Version @20 | 1 |
| `90 16` | INITWORD lib_Revision @22 | 5 |
| `80 18` | INITLONG lib_IdString @24 | .text+0x2e |
| `00000000` | terminator | |
