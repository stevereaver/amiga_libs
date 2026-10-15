---
type: Function
title: Framework vectors
---
# Framework

- LibInit (0xac): `moveal d0,a1; movel a0,a1@(34)` —
  stores only the seglist at base+0x22 (dataSize 0x26).
- LibOpen: opencnt++, `bclr #3,lib_Flags` (correct DELEXP).
- LibClose: opencnt--; at zero and DELEXP set, falls into
  Expunge; otherwise returns 0 via the hunk+0 stub.
- LibExpunge: opencnt>0 -> sets DELEXP, returns 0; else
  Remove(-252) + FreeMem(-210), returns seglist.
- LVO -24/-42/-48/-60: offset 0 -> the entry stub
  `moveq #0,d0; rts`.
