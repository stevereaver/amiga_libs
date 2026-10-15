# image_40.00_020_.library

"image.library 40.00 -  68020 ((28.5.99) 17:32:16)", "(c) 1993-99
Pawel Marciniak" — third-party image.library replacement. 6024B.

- 2 hunks: h0 CODE 0x55b, h1 DATA 0x47.
- Resident in the DATA hunk @h1+0xb0; name->h1+0x50,
  id->h1+0x60, init->h1+0 (InitTable at DATA start).
- InitTable: dsize 0x32, ftab->h1+0x10 (abs-long vectors ->h0),
  dtab->h1+0xcc, initfn->h0+0xe.
- init opens utility37 + graphics39.
