# Layout

- h0 CODE 0x494 @file 0x30: `7000 4e75` prologue, resident@+4,
  strings/code; name/id ptrs relocate ->h3.
- h1 DATA 4 longs @0x12f0: the InitTable itself.
- h2 DATA 0x91 @0x132c: globals.
- h3 CODE 0x1f @0x157c: 22-long functab + strings (hunk is CODE
  type holding data).
- h4 CODE 0x90 @0x166c: code.
- Relocs: h0 ->h0/h1/h2/h3/h4; h1 ->h0+->h3; h3 22 slots ->h0.
