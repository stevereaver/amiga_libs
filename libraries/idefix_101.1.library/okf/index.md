# idefix_101.1.library

"idefix.library 101.1 (13.02.99)" — IDE/ATAPI fix/patch
library (IDEFix '97-era). 6156B, 2 hunks: CODE 0x575 + DATA 0x53.

- Resident @h0+0x16 (mid-code); name->h0+0x90, id->h0+0x9f.
- InitTable @h0+0x2c: dsize 0xc0, ftab@h0+0x3c (15 abs-long
  vectors, entries relocate ->h0), dtab@h0+0x5e,
  initfn@h0+0xe0.
- init opens dos.library 37, calls exec -624 (AddDosEntry),
  dos -84/-228, exec -96/-132/-138/-222; closes dos + FreeMem
  on the tail path.
