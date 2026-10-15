# Layout

- h0 CODE 0x4f6 longs: stub+resident@+4, name/id strings, code.
- h1 DATA 0x74 longs @file 0x1480: banner text, functab @+0x34
  (14 slots ->h0 + ffffffff), InitTable @+0x6c, dep strings,
  "ENV:NewIcons.prefs", "DEFAULTIMAGE", globals.
- Relocs: h0 8->h0 + 16->h1; h1 14->h0 (functab) + 1->h1.
