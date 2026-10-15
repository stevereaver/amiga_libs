# newicon_middle-end_40.1.library

"newicon middle-end 40.1  (9.3.97)" — NewIcons middle-end shim
library. 5800B.

- 2 hunks: h0 CODE (0x4f6 longs, resident+strings+functab+InitTable),
  h1 DATA (0x74 longs: "*** DON'T EDIT THIS FILE ***" banner,
  functab@+0x34, InitTable@+0x6c, dep strings, ENV:NewIcons.prefs).
- Extended 26B resident @h0+4; name->h0+0x1e, id->h0+0x2e,
  init->h1+0x6c (cross-hunk).
- InitTable: dsize 0x3a, ftab->h1+0x34 (14 abs-long vectors ->h0),
  dtab 0, initfn->h0+0x32c.
- init opens dos37, graphics39, icon37; reads ENV:NewIcons.prefs.
