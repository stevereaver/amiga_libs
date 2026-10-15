---
bundle: mathtrans_31.2_WB1.1_.library
status: complete
updated: 2026-10-15
---
# mathtrans.library 31.2 (WB1.1)

Workbench 1.1 math transcendental library — 19-hunk per-function
link order (CODE x18 + one DATA hunk + 3 empty CODE hunks),
with MC68343-family FP firmware routines linked in. AUTOINIT
resident @h0+0, InitTable @h0+0x4c.

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
