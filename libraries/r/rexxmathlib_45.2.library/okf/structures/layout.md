# Layout

- h0 CODE 0x478 longs @file 0x24: stub+resident@+4, glue code.
- h1 DATA 0xf3 longs @file 0x123c: InitTable@+4, functab@+0x14
  (6 slots ->h0), strings: "rexxmathlib.library", "$VER: rexxmathlib
  45.2 (24.2.2001)", "mathieeedoubbas.library",
  "mathieeedoubtrans.library".
- Relocs: h0 1->h0 (+6 endskip) + 4->h1 (resident name/id/init/@+0x30);
  h1 6->h0 (functab) + 1->h1 (ftab self-ptr @+8).
