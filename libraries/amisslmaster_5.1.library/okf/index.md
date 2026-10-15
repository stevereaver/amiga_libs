# amisslmaster_5.1.library

"amisslmaster.library 5.1 (21.5.2022) os3-68020 version" — AmiSSL
master/dispatcher library. 5660B.

- 2 hunks: h0 CODE (0x546 longs; bra over strings, resident mid-hunk
  @h0+0x94), h1 DATA-tagged (32B of stub-looking code `600a2f0b...`).
- Extended 26B resident; name ->h0+4 "amisslmaster.library" (string
  sits right after the entry bra), id ->h0+0x1f; init ->h0+0x84.
- InitTable @h0+0x84: dsize 0x66, ftab->h0+0x58 (10 abs-long vectors),
  dtab 0, initfn->h0+0xe2.
- Relocs: h0 31->h0 + 7->h1; h1 none.
