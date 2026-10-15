# xarDUMMY_1.0.library

"xarDUMMY.library / Version 1.0" — ARexx host-protocol dummy
library. 6320B, 5 hunks: CODE 0x494 + DATA 4 + DATA 0x91 +
CODE 0x1f + CODE 0x90.

- Resident @h0+4 (flags 0x80, ver 1); name/id strings live in h3;
  init field relocates ->h1 (whole DATA hunk IS the InitTable:
  dsize 0x248, ftab ->h3+0 functab block, dtab 0, initfn ->h0+0x20).
- h3 is a 22-entry absolute-long functab (every entry relocated
  ->h0) + name/id strings.
- h4 is the bulk code hunk; h2 holds DATA globals.
