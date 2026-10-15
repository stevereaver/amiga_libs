---
file: layout
---
# rexxidentify 1.16 layout

File 3620B. Header: 2 hunks — h0 CODE 0x365 longs (3476B @0x24),
h1 BSS 0x80 longs (512B, no file body).
Tail: **DREL16** groups ->h0 (word count+hunkno+offsets, bare
0-word terminator, 4-byte-aligned) — unlike 1.15's RELOC32.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #0,d0 / rts` module stub |
| 0x04 | Resident: AUTOINIT (0x80), ver 1, rev 16; name->0x1e id->0x33 init->0x100 |
| 0x100 | InitTable: dsize 0x2c, functab->0x110, datatab->0x128, initfn->0x148 |
| 0x110 | functab — 5 absolute longs +0x24e/0x25c/0x270/0x2e6/0x2ea, `ffffffff` |
| 0x128 | InitData records (InitStruct: lib_Version=30 etc.) |

hunk1 BSS 512B — runtime context (ARexx msgport/host state).
