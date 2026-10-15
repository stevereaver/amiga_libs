# icon_33.127_WB1.2_.library

"icon 33.127 (22 Jul 1986)" — the WB1.2 Commodore icon.library,
the oldest build in the archive. 5996B.

- 15 hunks (per-function build, like icon_34.2): h0 CODE 0xa2
  (resident+shared glue), h5 CODE 0x283 (main body), several small
  CODE hunks, h6 DATA 0xd, four empty hunks (h2/h4 DATA, h9/h11/
  h14 CODE/DATA), heavy interleaved RELOC32 web (incl. forward
  refs to h5/h7/h8/h10/h12/h13).
- Resident @h0+4 (standard 26B); name->h0+0x1e, id->h0+0x2b,
  init->h0+0x48.
- InitTable: dsize 0x2e, ftab@h0+0x58, dtab@h0+0xa4, initfn
  h0+0x148.
