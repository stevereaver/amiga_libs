# pccard_2.2.library

"pccard.library 2.2 (15.12.2024)" — PCMCIA CIS tuple parser. 5844B.
Same family as pccard_2.1, +20B code.

- Flat single CODE hunk (0x577 longs), AUTOINIT.
- Resident @h0+0x4a; InitTable@h0+0xa2: dsize 0x2e, ftab@0x64
  (7 abs-long vectors), dtab@0x84, initfn@0xb2.
- init opens utility.library v36.
