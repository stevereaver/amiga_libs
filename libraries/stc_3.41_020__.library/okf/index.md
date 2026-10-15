# stc_3.41_020__.library

"StoneCrackerLibrary 3.41 (16 Feb 1995)" — STC file cruncher
library (S604/StoneCracker packer family). 6168B, flat CODE
hunk 0x5ef.

- Resident @h0+4 (flags 0x80, ver 3); InitTable@h0+0xce:
  dsize 0x4a, ftab@h0+0xde (20 abs-long vectors ->h0),
  dtab@h0+0x10a, initfn@h0+0x12a.
- init calls exec -408 (OldOpenLibrary) 3x: "stc.library"-adjacent
  deps @h0+0x7e/0x8a/0x9b strings (dos + utility family).
- RELOC32: 10 slots ->h0.
