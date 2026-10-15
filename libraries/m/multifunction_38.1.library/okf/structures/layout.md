---
file: layout
---
# multifunction 38.1 layout

File 5432B. Header 0x3f3, no names, 1 hunk, table [0x50c].
h0 CODE @0x18, body @0x20 (0x50c longs = 5168B). Tail:
RELOC32 @0x1450, 53 slots ->h0, END @0x1534.

- body+0: `moveq #-1,d0;rts`
- body+4: Resident 4afc, match->+4, endskip->+0x142e,
  flags 0x80 AUTOINIT, ver 38, type NT_LIBRARY, pri 0,
  name->+0x1e, id->+0x34, init->+0x7c.
- body+0x1e: "multifunction.library"; +0x34 id
  "... by Michael Boese & Matthias Bethke . 1997-1998\r\n".
- body+0x7c: InitTable — dsize 0x62, ftab->+0x8c, dtab->+0x10c,
  initfn->+0x140.
- body+0x8c: 31 abs-long vectors, 0xffffffff term @+0x108.
- body+0x10c: InitData — ln_Type=9@8, ln_Name@0xa, lib_Flags=6
  @0xe, ver 38@0x14, rev 1@0x16, IdString@0x18, word 0x07ff
  @0x2a (resource mask), words 0 @0x2c/0x5c/0x60.
- body+0x140: initfn `move.l a0,($13c).l`->h0+0x13c (seglist
  slot), rts.
- body+0x148..0x1430: code + embedded strings
  (commodities.library@0x31a, intuition@0x916, graphics@0x928,
  "Can't allocate %s bits!"@0xb70, "Can't open misc.resource"
  @0xb94, timer.device@0x1012, MFLIB_DEBUG@0x123e,
  dos.library@0x12cc).

Lib base (0x62): 0x22 execbase, 0x26 misc.resource base,
0x2a claim mask, 0x2c pending mask, 0x2e SignalSemaphore(46B),
0x5c alloc count, 0x60 saved bits.

Reloc slots: RomTag 5 (+6,a,12,16,1a), InitTable+vectab 34
(0x80..0x104), InitData ptrs 0x112/0x124, initfn operand 0x142,
code refs 0x48a/0x496/0x4cc/0x4e2/0x4fc/0x590/0x596/0x944/
0x948/0xb50/0x11f8.
