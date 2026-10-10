---
type: Structure
title: InitTable
description: AUTOINIT table, absolute-long function table, compact InitStruct data.
resource: source/fwfiltertype_lib.s
timestamp: 2026-10-10T19:15:00Z
---

# InitTable

RomTag at .text+4: `RTF_AUTOINIT` (0x80), rt_Version=3, NT_LIBRARY (9),
rt_Pri=0. `rt_Init` points to the four-field init table at .text+0x7e:

```
dc.l   0x28          | dataSize
dc.l   _functab      | function table (.text+0x8e)
dc.l   _datatab      | InitStruct data (.text+0xaa)
dc.l   _LibInit      | init vector (.text+0x138)
```

## Function table

Absolute longword addresses (first word 0x0000 → pointer
interpretation), `-1L` terminated, 6 entries:

Open(-6), Close(-12), Expunge(-18), LibNull(-24), FwFilterType(-30),
LibNull(-36 — same stub address as -24).

## InitStruct data (compact byte-offset commands)

| command | field | value |
|---------|-------|-------|
| `a0 08` | INITBYTE ln_Type @8 | 9 (NT_LIBRARY) |
| `80 0a` | INITLONG ln_Name @10 | "fwfiltertype.library" |
| `a0 0e` | INITBYTE lib_Flags @14 | 6 (LIBF_SUMUSED\|LIBF_CHANGED) |
| `90 14` | INITWORD lib_Version @20 | 3 |
| `90 16` | INITWORD lib_Revision @22 | 0 |
| `80 18` | INITLONG lib_IdString @24 | .text+0x39 — inside "$VER:" string |
| `0000`  | terminator + pad | |

`lib_IdString` points *after* the `"$VER: "` cookie at .text+0x39, so it
reads `"fwfiltertype.library 3.0 (6.8.93)\n"`; the version scanner
finds `$VER:` because the cookie bytes are adjacent. Same trick as the
680x0.library dispatcher (see
../../680x0_40.4.library/okf/index.md).
