# conhandler_1.1.library

"conhandler 1.1 (04 FEB 88)" — early console-handler support
library. 6152B, single CODE hunk 0x5d0.

- Resident @h0+4 (flags 0x80, ver 33, type NT_LIBRARY).
- rt_Init -> h0+0x20 = InitTable: dsize 0x6a, ftab@h0+0x30
  (27 abs-long vectors ->h0), dtab@h0+0xa0, initfn@h0+0xde.
- init opens intuition.library 33.
- RELOC32: 37 slots, all ->h0.
