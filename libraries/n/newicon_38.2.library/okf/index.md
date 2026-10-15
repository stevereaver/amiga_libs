# newicon_38.2.library

"newicon 38.2 (13.7.95)" — earlier NewIcons library, same family as
newicon_middle-end_40.1 (AMIGALIBS-383). 5848B.

- 2 hunks: h0 CODE (0x50b longs), h1 DATA (0x6e longs).
- Resident @h0+4 (26B, AUTOINIT); name->h0+0x1e, id->h0+0x2e,
  init relocates ->h1+0x68 (InitTable in DATA hunk).
- InitTable: dsize 0x2e, ftab->h1+0x34 (abs-long vectors ->h0),
  dtab 0, initfn->h0+0x330.
- init opens dos37, graphics37, icon37; DATA hunk carries the
  "*** DON'T EDIT THE FOLLOWING LINES ***" banner + DEFAULTIMAGE
  data.
