# Layout

- h0 CODE 0x55b longs @file 0x24: code only, strings sit in h1.
- h1 DATA 0x47 longs @file 0x15fc: InitTable@+0, functab@+0x10,
  name/id/dep strings, resident@+0xb0.
- Relocs: h0 20->h1; h1 12->h0 (functab) + 9->h1.
