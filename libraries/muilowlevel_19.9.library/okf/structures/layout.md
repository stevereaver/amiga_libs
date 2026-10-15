---
file: layout
---
# muilowlevel 19.9 layout

File 4172B. 2 hunks:
- h0 CODE 0x3b8 longs (3808B @0x24): head 'muilowlevel.library'
  + '$VER: muilowlevel 19.9 (12.97) (C)1992-1997 Stefan Stuntz',
  RomTag @+0x5e (flags 0 COLDSTART, ver 19, type 9,
  name->+4, id->+0x1e, init->+0xd8), ASCII table @+0x76
  ('_`abcdefghijklmnopqrst...'), code, functab @+0xd38
  (33 relocated longs + ffffffff).
- h1 BSS 4 longs (16B, no body).

Relocs: 39 ->h0 (5 resident fields, 33 functab, 1 code @0xe22),
30 ->h1 BSS global refs.

initfn @h0+0xd8: MakeLibrary(functab@0xd38, 0, 0, dsize 0x54,
seglist), sets lib type 9 / ver 19 / name, NewList at +20,
InitSemaphore, then calls internal setup @0x250; failure path
FreeMem(neg+pos) and return 0.
