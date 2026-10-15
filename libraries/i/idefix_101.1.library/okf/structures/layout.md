# Layout

- h0 CODE 0x575 @file 0x24: `4e71 4e75` prologue, resident@+0x16
  (mid-code, after the nop/rts), InitTable@+0x2c, functab@+0x3c,
  datatab@+0x5e, strings near +0x90, bulk code after.
- h1 DATA 0x53 @file 0x1698.
- Relocs: h0 16->h0 + 15->h1; h1 5->h0.
