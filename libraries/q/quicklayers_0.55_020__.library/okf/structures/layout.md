---
file: layout
---
# quicklayers 0.55 layout

File 4968B. Two CODE hunks: h0 0xba longs (744B @0x24),
h1 0x3e5 longs (3988B @0x3a0). RELOC32 tails: h0 12 slots
->h1 + 16 ->h0; h1 3 ->h1 + 3 ->h0.

Resident @h0+4: packed RomTag, flags 0x81, ver 0, type 9;
name "quicklayers.library", id "quicklayers.library 0.55
(06.12.2005) 68020+ by Sante Nocciolino". init->h0+0xb0.
InitTable @h0+0xb0: dsize 0x3c, ftab->h0+0xc0 (4 abs longs
->h0), dtab->h0+0xd4, initfn->h0+0xf8.

Patch table @h0+0x220: 12 records {u16 field?, h1 ptr, u32}
— the ->h1 relocs sit at every third long (stride 0xc) —
used by initfn to rewrite the copied module's 4eba jmp
slots to point into h1.
