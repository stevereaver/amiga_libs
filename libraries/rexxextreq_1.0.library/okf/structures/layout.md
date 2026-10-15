# Layout

- h0 CODE 0x545 longs @file 0x28: resident@+4, initfn@+0x20,
  requester code, dep-name strings, "***NULL POINTER***" assert.
- h1 DATA 0x4e longs @file 0x158c: InitTable@+4 + globals.
- h2 CODE 0x14 longs @file 0x16f0: functab@+0 + "rexxextreq.library"
  name/id strings.
- Relocs: h0 2->h0+3->h1+4->h2; h1 1->h0+1->h2; h2 5->h0.
