---
bundle: catharsis_2.11.library
status: complete
updated: 2026-10-15
---
# catharsis.library 2.11 (27-Apr-03)

SAS/C-style 3-hunk library: h0 CODE 0x440 longs (code + RomTag
at +0xe70), h1 DATA 0x32 longs (dep-name strings, name/idstring,
23-entry abs-long functab, InitTable), h2 BSS 4 longs.
AUTOINIT ver 2, NT_LIBRARY, pri 0. Deps: graphics.library and
intuition.library, both opened at v33 during init. Private data
area is 0x866 bytes incl. a semaphore-guarded 256-slot resource
table swept free on expunge.

- `structures/layout.md` — hunk map, RomTag, InitTable, BSS
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks (relocated-0 vector ->CODE+0)
