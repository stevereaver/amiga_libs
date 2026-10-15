---
file: layout
---
# dsp3210 3.4 layout

File 4436B. 1 hunk: CODE 0x429 longs (4260B @0x20).

Resident @h0+4: packed, flags 0 COLDSTART, ver 3, type 9;
name->+0x1e, id->+0x34 ('$VER: dsp3210.library 3.4'),
init->+0x9c.

rt_Init @+0x9c: lea pc@(functab=+0x170),a0; MakeLibrary(ftab,
0, initfn@+0xc8, dsize 0x2c, seglist); AddLibrary; ret 1.
Functab @h0+0x170: 14 absolute longs + ffffffff.
Tail: 5 RELOC32 ->h0 (resident fields) + END.
