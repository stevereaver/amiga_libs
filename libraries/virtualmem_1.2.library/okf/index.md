---
bundle: virtualmem_1.2.library
status: complete
updated: 2026-10-15
---
# virtualmem.library 1.2 (7.8.97)

Virtual-memory manager library. 2 hunks: h0 CODE 0x46a
longs (resident+InitTable+code), h1 DATA 0x2f longs
(functab + scratch). AUTOINIT ver 0 (id says 1.2).
17 vectors.

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table + deps
- `findings/defects.md` — quirks
