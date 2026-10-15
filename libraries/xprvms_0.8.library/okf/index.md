# xprvms_0.8.library

"xprvms 0.8 (18 Oct. 1991)" — XPR serial-transfer protocol
module (VMS flavor), sibling of xprdmodem/xprjmodem. 6308B,
2 hunks: CODE 0x5d8 + DATA 0x17.

- Resident @h0+4 (flags 0x80, ver 0); InitTable@h0+0x4a:
  dsize 0x26, ftab@h0+0x5a (10 abs-long vectors ->h0),
  dtab@h0+0x86, initfn@h0+0xb2.
- Relocs: h0 26->h0 + 13->h1; h1 none.
