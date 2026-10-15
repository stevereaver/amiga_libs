# rexxmathlib_38.03.library

"rexxmathlib 38.03 (26.10.2000) © THOR" — ARexx math function library.
5760B, m68000.

- 2 hunks: h0 CODE (0x486 longs), h1 DATA (0xf5 longs) — resident
  sits in h0 but name/id/init relocate ->h1 (strings + InitTable in
  DATA hunk).
- Resident @h0+4 (22B standard): endskip->h0+4, extra-slot 0.
  name->h1+0x2c, id->h1+0x46, init->h1+4 (InitTable).
- InitTable @h1+4: dsize 0x98, ftab->h1+0x14 (6 abs-long vectors
  relocated ->h0 code), dtab 0, initfn->h0+0x1e.
- deps opened at init: mathieeedoubbas.library (v37),
  mathieeedoubtrans.library (v34) + 2 more.
