---
file: vectors
---
# Vectors

7 LVOs (-6 .. -42). Functab @h3+0 (absolute longs, post-reloc):
open/close/expunge/reserved ->h1 (0xa6/0xc2/0xec) + stubs ->h0+0,
h5+0, h4+0, h4+0x24.

initfn ->h1+0; datatab=0 (no InitStruct data).

Observed: open bumps count ->lib; regexp entry (-30) returns 1
under stub deps; -42 returns -1.
