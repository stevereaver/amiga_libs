# iffparse.library_45.3_WB3.2_

"iffparse 45.3" (WB3.2 build) — Commodore IFF parser library, 6108B.

- 2 hunks: h0 CODE 0x5d7, h1 DATA 1 long (zero).
- Resident @h0+4; InitTable@h0+0x4c: dsize 0x34,
  ftab@h0+0x5c (45 abs-long vectors ->h0), dtab 0,
  initfn@h0+0xba.
- init opens dos.library 37 + utility.library 37.
