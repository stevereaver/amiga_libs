---
bundle: powerpacker_37.0_020__.library
status: complete
updated: 2026-10-15
---
# powerpacker.library 020+ 37.0 (06.11.96, "pplib 020+")

PowerPacker cruncher library, 68020+ build. Single h0 CODE
(alloc 0x5ad longs / body 0x5a3 — 40B trailing pad is the
runtime globals area). AUTOINIT ver 37. 23 word-offset
vectors. initfn OldOpenLibrarys intuition/graphics/dos and
SetFunction-patches exec FreeMem(-210) with a 'PPMM'
header-stripping hook (restored on expunge).

- `structures/layout.md` — hunk map, resident, InitTable, globals pad
- `functions/vectors.md` — LVO table + deps
- `findings/defects.md` — quirks (datatab writes lib 36.10 vs idstring 37.0)
