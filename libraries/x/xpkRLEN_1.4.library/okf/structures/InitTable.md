---
type: Structure
title: InitTable
description: AUTOINIT table; word-offset function table with -1 marker.
resource: source/xpkRLEN_lib.s
timestamp: 2026-10-10T09:40:00Z
---

# InitTable

RomTag at .text+0x04 with `RT_ENDSKIP` = .text+0x278 (the very end of
the module — the resident scanner covers the whole hunk). InitTable at
.text+0x1e:

```
dc.l   0x2a          | dataSize = sizeof(XpkSubBase)
dc.l   FUNCTABLE     | .text+0x2e
dc.l   DATATABLE     | .text+0x46
dc.l   INITFUNCTION  | .text+0xd4
```

RomTag fields: `RTF_AUTOINIT`, version 1, NT_LIBRARY, pri 0,
name .text+0x66, idstring .text+0x76 (no `$VER:` cookie).

## Function table — word-offset format

12 words at .text+0x2e: `-1` marker, 10 offsets relative to the table
base, `-1` terminator.

| LVO | word | target |
|----:|------|--------|
| -6  | 0x00ae | LibOpen .text+0xdc |
| -12 | 0x00bc | LibClose .text+0xea |
| -18 | 0x00ca | LibExpunge .text+0xf8 |
| -24 | 0x0100 | LibNull .text+0x12e |
| -30 | 0x012a | XpksPackerInfo .text+0x158 |
| -36 | 0x0132 | XpksPackChunk .text+0x160 |
| -42 | 0x0100 | LibNull |
| -48 | 0x0100 | LibNull |
| -54 | 0x0104 | XpksUnpackChunk .text+0x132 |
| -60 | 0x0100 | LibNull |

## InitStruct data (compact byte-offset commands at .text+0x46)

| command | field | value |
|---------|-------|-------|
| `a0 08` | INITBYTE ln_Type @8 | 9 (NT_LIBRARY) |
| `80 0a` | INITLONG ln_Name @10 | "xpkRLEN.library" |
| `a0 0e` | INITBYTE lib_Flags @14 | 6 |
| `90 14` | INITWORD lib_Version @20 | 1 |
| `90 16` | INITWORD lib_Revision @22 | 4 |
| `80 18` | INITLONG lib_IdString @24 | .text+0x76 |
| `0000`  | terminator | |
