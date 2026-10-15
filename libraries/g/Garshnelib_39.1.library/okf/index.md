---
bundle: Garshnelib_39.1.library
status: complete
updated: 2026-10-15
---
# Garshnelib.library 39.1 (23.10.94)

Game-support library (Garshne BBS/door game engine) —
SAS/C-style hand-rolled init. 2 hunks: CODE 0x435 longs
(+4B overrun) + DATA 0x34 longs (forward pointer table).
16-entry abs-long functab (one NULL hole).

- `structures/layout.md` — hunk map, resident, lib fields
- `functions/vectors.md` — functab entries
- `findings/defects.md` — degenerate resident quirk
