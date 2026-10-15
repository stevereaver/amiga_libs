---
file: layout
---
# rexxidentify 1.12 layout

File 3812B. Header declares 2 hunks: hunk0 CODE 0x370 longs (3520B
body @file+0x24), hunk1 BSS 0x80 longs (512B, no file body).
RELOC32 tail: 32 slots ->h0 + 6 slots ->h1 (at h0 offsets
0x1b4,0x454,0xac0,0xb34,0xb94,0xc90 — pointers into the BSS work
area).

## hunk0

| off | contents |
|-----|----------|
| 0x00 | stub `moveq #0,d0 / rts` |
| 0x04 | Resident AUTOINIT v1, pri 0; name->0x1e id->0x33 init->0x100 |
| 0x5c.. | banner/copyright/LGPL/source-url strings |
| 0xe0 | InitTable: dsz=0x2c, functab->0xf0, datatab->0x108, initfn->0x128 |
| 0xf0 | functab: 5 absolute longs 0x22e,0x23c,0x250,0x2c6,0x2ca + -1 |
| 0x204 | dep strings: rexxsyslib.library, expansion.library, commodities.library, identify.library |
| 0x34a+ | ARexx command name table (ID_*, MANUF, CLASS, SYSTEM, OSVER, CHIPSET, AGNUS, DENISE, BOINGBAG, ...) |
