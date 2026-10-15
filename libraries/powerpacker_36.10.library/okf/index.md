---
bundle: powerpacker_36.10.library
status: complete
updated: 2026-10-15
---
# powerpacker.library 36.10 (28.9.93, "pplib")

Nico Francois' PowerPacker cruncher library (1993, newer
sibling of 35.344). h0 CODE 0x5b9 longs + h1 BSS 4 longs.
AUTOINIT ver 36. 23 abs-long vectors (one more than 35.344).
initfn SetFunction-patches exec FreeMem ('PPMM' hook).

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table + deps
- `findings/defects.md` — quirks
