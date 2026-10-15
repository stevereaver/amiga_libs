---
file: layout
---
# sage 36.2 layout

File 4420B. 2 hunks:
- h0 CODE 0x3db longs (3948B @0x24): stub+id head
  ('SAGE 36.2 (1 May 1992)' — id has no $VER: prefix),
  RomTag@+0x1e, code, functab@+0xe5c (10 longs), name str@0xe88.
- h1 DATA 0x4b longs (300B @0xffc): [0]=0, InitTable@+4:
  dsize 0x192, functab->h0+0xe5c, dtab 0, initfn->h0+0x38;
  rest zero/padding.

Resident (flags 0x80 AUTOINIT, ver 36, type 9): name->h0+0xe88,
id->h0+4, init->h1+4 — init pointer relocates INTO h1.

Relocs: h0 15->h0 + 3->h1; h1 2->h0.
initfn@h0+0x38 opens graphics.library v33.
