---
type: Structure
title: InitTable
description: AUTOINIT table inside the RomTag endskip range; compact InitStruct.
resource: source/xpknone_lib.s
timestamp: 2026-10-10T19:45:00Z
---

# InitTable

RomTag sits at .text+0x84 — deep inside the hunk, *after* the function
table, padding, InitStruct data and InitTable it references (legal;
the resident scanner just finds the `4afc` matchword).

```
dc.l   0x2a          | dataSize = sizeof(XpkSubBase)
dc.l   _functab      | .text+0x04
dc.l   _datatab      | .text+0x54
dc.l   _LibInit      | init vector
```

RomTag fields: `RTF_AUTOINIT`, version 1, NT_LIBRARY, pri 0,
name .text+0x9e, idstring .text+0xae, RT_ENDSKIP = .text+0x9e (the
first byte after the tag — the name string itself).

## Function table

Absolute longword table at .text+0x04 — *before* all other tables —
10 entries + -1L:

Open, Close, Expunge, LibNull, XpksPackerInfo, XpksPackChunk,
LibNull, LibNull, XpksUnpackChunk, LibNull.

## InitStruct data (compact byte-offset commands at .text+0x54)

| command | field | value |
|---------|-------|-------|
| `a0 08` | INITBYTE ln_Type @8 | 9 (NT_LIBRARY) |
| `80 0a` | INITLONG ln_Name @10 | "xpkNONE.library" |
| `a0 0e` | INITBYTE lib_Flags @14 | 6 |
| `90 14` | INITWORD lib_Version @20 | 1 |
| `90 16` | INITWORD lib_Revision @22 | 4 |
| `80 18` | INITLONG lib_IdString @24 | .text+0xae (no `$VER:` cookie!) |
| `0000`  | terminator + pad | |
