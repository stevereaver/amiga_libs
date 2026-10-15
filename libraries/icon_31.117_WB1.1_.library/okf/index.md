# icon_31.117_WB1.1_.library

"icon 31.117 (23 Nov 1985)" — the WB1.1 Commodore icon.library,
the FIRST released icon.library. 6100B.

- 16 hunks (per-function build): h0 CODE 0xa2 (resident+glue),
  h5 CODE 0x287 (main body), many small CODE hunks, h6 DATA 0xd,
  five empty hunks (h2/h4/h15 DATA + h8/h13 CODE); dense
  interleaved RELOC32 web with forward refs.
- Resident @h0+4 (26B); name->h0+0x1e, id->h0+0x2b ("icon 31.117
  (23 Nov 1985)"), init->h0+0x48.
- InitTable: dsize 0x2e, ftab@h0+0x58, dtab@h0+0xa4, initfn
  h0+0x148 — identical table geometry to the WB1.2 33.127 build.
