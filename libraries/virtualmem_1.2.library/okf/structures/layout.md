---
file: layout
---
# virtualmem 1.2 layout

File 5000B. h0 CODE 0x46a longs (4520B @0x24), h1 DATA
0x2f longs (188B @0x1274). RELOC32: h0 30 slots ->h0 +
3 ->h1; h1 17 slots ->h0 (the functab).

Resident @h0+6, 26-byte extended variant (same family as
hgrexxsupport): MatchTag, EndSkip->h0+6 self, extra ptr
@+6 ->h0+0x20 (the InitTable), flags 0x80 AUTOINIT @+0xa,
ver 0, type 9, pri 0; Name@+0xe ->h0+0x120
"virtualmem.library", IdString@+0x12 ->h0+0x133 "$VER:
virtualmem.library 1.2 (7.8.97)", Init@+0x16 ->h0+0x20.

InitTable @h0+0x20: dsize 0x2c, ftab->h1+4 (17 abs longs
->h0), dtab 0, initfn->h0+0x30.
