# rexxextreq_1.0.library

"rexxextreq.library 1.0 (02/10/97)" — ARexx extended-requester
library ("ExtendedRequest"). 5992B.

- 3 hunks: h0 CODE 0x545 (resident+code), h1 DATA 0x4e
  (InitTable@guts+globals), h2 CODE 0x14 (functab + name/id
  strings + tail stubs).
- Resident @h0+4 (standard 26B); name->h2+0x18, id->h2+0x2c,
  init->h1+4 — InitTable lives in the DATA hunk.
- InitTable: dsize 0x168, ftab->h2+0 (6 abs-long vectors,
  entries relocate ->h0), dtab 0, initfn->h0+0x20.
- init opens intuition37, gadtools37, utility37, rexxsyslib0,
  keymap36, graphics37.
