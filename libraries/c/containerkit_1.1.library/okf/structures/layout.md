---
file: layout
---
# containerkit 1.1 layout

File 4432B. 2 hunks:
- h0 CODE 0x408 longs (4128B @0x24): `moveq#-1/rts` stub @0,
  absolute functab @+4 (29 longs->h0), all code+strings.
- h1 DATA 0xb longs (44B @0x10ec): InitTable @+0
  {dsize 0xdc, functab->h0+4, dtab 0, initfn->h0+0xd6},
  RomTag @h1+0x10 (flags 0x80 AUTOINIT, ver 1, type 9,
  name->h0+0x98, id->h0+0xae, init->h1+0).

Relocs: h0 functab+code refs; h1 4->h0 + 3->h1.
