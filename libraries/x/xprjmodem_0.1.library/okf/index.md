# xprjmodem_0.1.library

"xprJModem" (XPR JModem protocol module). 6396B, 3 hunks:
CODE 0x5ef + DATA 0x1d + BSS 1.

- Resident @h0+0xc (mid-code); init field relocates ->h1+0x24:
  the InitTable lives in the DATA hunk (dsize 0x2a, ftab->h1+0
  functab block, dtab 0, initfn->h0+0x20).
- 8 abs-long vectors ->h0, one entry (idx 3) = 0.
- Relocs: h0 9->h0 + 4->h1; h1 8->h0 + 1->h1.
