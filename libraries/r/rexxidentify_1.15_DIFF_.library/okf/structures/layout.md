---
file: layout
---
# rexxidentify 1.15 (DIFF) layout

File 3728B. Header declares 2 hunks: hunk0 CODE 0x380 longs (3584B
body @file+0x24), hunk1 BSS 0x80 longs (512B, no file body).
DREL16 tail: same slot list as the 1.15 build (32 ->h0 + 6 ->h1) encoded as 16-bit words (at h0 offsets
0x1b4,0x454,0xac0,0xb34,0xb94,0xc90 — pointers into the BSS work
area).

## hunk0

| off | contents |
|-----|----------|
| 0x00 | stub `moveq #0,d0 / rts` |
| 0x04 | Resident AUTOINIT v1, pri 0; name->0x1e id->0x33 init->0x100 |
| 0x5c.. | banner/copyright/LGPL/source-url strings |
| 0x100 | InitTable: dsz=0x2c, functab->0x110, datatab->0x128, initfn->0x148 |
| 0x110 | functab: 5 absolute longs 0x24e,0x25c,0x270,0x2e6,0x2ea + -1 |
| 0x204 | dep strings: rexxsyslib.library, expansion.library, commodities.library, identify.library |
| 0x34a+ | ARexx command name table (ID_*, MANUF, CLASS, SYSTEM, OSVER, CHIPSET, AGNUS, DENISE, BOINGBAG, ...) |
