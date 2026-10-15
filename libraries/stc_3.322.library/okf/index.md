# stc_3.322.library

"StoneCrackerLibrary 3.322 (17 Apr 1994)" — older STC cruncher
build, sibling of stc_3.41(020+). 6368B, CODE 0x61a + BSS 0x41.

- Resident @h0+8 (after a `4e75`-style prologue); InitTable
  @h0+0xd8: dsize 0x4a, ftab@h0+0xe8 (20 abs-long vectors ->h0),
  dtab@h0+0x114, initfn@h0+0x134.
- init opens 3 deps via OldOpenLibrary(-408).
- Relocs: h0 10->h0 + 1->h1.
