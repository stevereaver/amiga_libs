---
bundle: rexxhost_36.14.library
status: complete
updated: 2026-10-15
---
# rexxhost.library 36.14 (09 Sep 1990)

Original Commodore-era ARexx host-function library — the
application-side interface for registering ARexx function hosts /
host ports. 3 hunks: CODE (3360B) + DATA (120B, functab+InitTable)
+ BSS (4B). 21 vectors. Deps: dos.library, rexxsyslib.library.

- `structures/layout.md` — hunk map, resident, cross-hunk InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
