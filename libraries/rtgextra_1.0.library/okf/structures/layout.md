---
file: layout
---
# rtgextra 1.0 layout

File 4328B. 3 hunks:
- h0 CODE 0x3d4 longs (3920B @0x28): stub+resident+initfn+all code.
- h1 CODE 0x18 longs (96B @0xfd0): functab (15 relocated longs
  + ffffffff) then 'rtgextra.library'@+0x40 'Version 1.0'@+0x55.
- h2 DATA 0xd longs (52B @0x1088): [1]=dsize 0x144, [2]+reloc
  functab->h1+0, [3]=0 dtab, [4]+reloc initfn->h0+0x20, then
  extra word data (0xcd0/0xd10/0x1000/0x140/0x100/0x280 cells,
  some relocated ->h0).

Resident @h0+4: packed, flags 0x80 AUTOINIT, ver 38, type 9;
name->h1+0x40, id->h1+0x54, init->h2+4 (all relocated fields).

Reloc summary: h0 gets 4->h0 + 4->h1 + 3->h2; h1 15->h0;
h2 3->h0 + 1->h1.
