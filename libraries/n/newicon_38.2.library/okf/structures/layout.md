# Layout

- h0 CODE 0x50b longs @file 0x24: stub+resident@+4, strings, code.
- h1 DATA 0x6e longs @file 0x14cc: banner, functab@+0x34,
  InitTable@+0x68, dep strings, DEFAULTIMAGE image data.
- Relocs: h0 7->h0 + 15->h1; h1 13->h0 + 1->h1.
