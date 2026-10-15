---
bundle: mmvx_6.00.library
status: complete
updated: 2026-10-15
---
# mmvx.library 6.00 (21 Feb 1994)

MultiView-extensions (MMXV) support library. Plain resident
(flags=0): init@h0+0x80 loads exec base directly and calls
MakeLibrary(dsize 0x2a, functab@h0+0x1a8, initfn@h0+0xac) +
AddLibrary. 41 vectors.

- `structures/layout.md` — hunk map, resident, functab
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
