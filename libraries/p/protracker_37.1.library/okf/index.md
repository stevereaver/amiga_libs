# protracker_37.1.library

"protracker.library 37.1 (16-Nov-92)" — ProTracker module player
library. 5624B, m68000.

- Flat single-hunk AUTOINIT (CODE 0x535 longs), 60 RELOC32 slots ->h0.
- Extended 26-byte resident @h0+4 (extra ptr -> h0+0x14d2);
  `moveq#-1/rts` stub at body+0; ver 37, type 9.
- Name ->h0+0x1e, id ->h0+0x31; InitTable @h0+0x6c:
  dsize 0x28, ftab->h0+0x7c (6 abs-long vectors), dtab->h0+0x98,
  initfn->h0+0xb8.
