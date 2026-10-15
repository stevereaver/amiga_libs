---
file: layout
---
# amisslmaster 3.6 layout

File 3964B. 2 hunks: h0 CODE 0x2b2 longs (2760B @0x24),
h1 DATA 0x102 longs (1032B @0xb58).
Tail: RELOC32 — 15 ->h0, 3 ->h1, END.

## hunk0

| off | contents |
|-----|----------|
| 0x00 | `moveq #0,d0 / rts` stub |
| 0x04 | PACKED Resident: matchtag@+4, flags 0x80 AUTOINIT, ver 3, type 9; name@+0x12->h0+0xa2c, id@+0x16->h0+0xa44 ('amisslmaster.library 3.6 (4.3.2006) 68000 version'), init@+0x1a->h1+4 |
| 0xa04 | functab: 9 absolute longs ->h0 (+0xec/+0x232/+0x29e/0/+0x474/+0x496/+0x688/+0x734/+0x8fc) |

## h1 (DATA)

InitTable@+4: dsize 0x4d0, functab->h0+0xa04, datatab=0,
initfn->h0+0x20. Rest: '$VER:...' string + amissl child-lib tables.
