---
file: layout
---
# regexp 38.1 layout

File 5220B. h0 CODE 0x451 longs (4420B @0x24), RELOC32
10 slots ->h1. h1 DATA record @0x11a4, 0x85 longs
(532B @0x11ac), RELOC32 two groups: 25 ->h0 (functab +
internal jump table + InitTable initfn), 9 ->h1
(resident name/id/init + InitTable ftab/dtab + 2 data
ptrs).

Resident @h1+0x84: standard 22B, flags 0x80 AUTOINIT,
ver 38, name->h1+0x40 "regexp.library", id->h1+0x50
"regexp.library 38.1 (26.2.98)" + GPL text, init->h1+0.

InitTable @h1+0: dsize 0x2e, ftab->h1+0x10 (8 abs longs
->h0, -1 term), dtab->h1+0xa0, initfn->h0+4. A second
16-ptr jump block sits at h1+0xc8..0x104 ->h0.
