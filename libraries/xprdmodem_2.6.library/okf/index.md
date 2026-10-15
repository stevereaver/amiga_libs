# xprdmodem_2.6.library

"xprDModem 2.6 (08.06.94)" — XPR serial protocol module
(dual-modem flavor), sibling of xprvms/xprjmodem. 6320B,
2 hunks: CODE 0x5f6 + BSS 0x81.

- Resident @h0+4 (flags 0x80, ver 2); InitTable@h0+0x8a:
  dsize 0x30, ftab@h0+0x9a (8 abs-long vectors ->h0),
  dtab@h0+0xbe, initfn@h0+0xde.
- Relocs: h0 31->h0 + 4->h1(BSS).
- init opens dos.library v0.
