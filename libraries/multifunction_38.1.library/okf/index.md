# multifunction_38.1.library

"multifunction.library by Michael Boese & Matthias Bethke (c) 1997-1998"
— RTG/bitmap utility library, v38 r1. 5432B, m68000.

- Flat single-hunk (CODE 0x50c longs) AUTOINIT library.
- Extended 26-byte resident @h0+4 (extra pointer @+0xa -> h0+0x142e,
  same stub family as hgrexxsupport/virtualmem); body+0 is a
  `moveq #-1,d0;rts` stub (relocated-zero vector target).
- InitTable @h0+0x7c: dsize 0x62, functab->h0+0x8c, dtab->h0+0x10c,
  initfn->h0+0x140.
- 31 absolute-longword vectors + 0xffffffff terminator.
- 53 RELOC32 slots, all ->h0.
