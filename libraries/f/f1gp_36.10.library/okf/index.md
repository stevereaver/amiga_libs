---
bundle: f1gp_36.10.library
status: complete
updated: 2026-10-15
---
# f1gp.library 36.10

F1GP (Formula 1 Grand Prix) support library — WarpOS-era
68k/PPC hybrid. 2 hunks: h0 68k CODE, h1 DATA holding embedded
PowerPC instruction words (installed/copied by init). Plain
non-AUTOINIT resident; COLDSTART init @+0x6c clears the a4 BSS
frame then falls into the MakeLibrary+AddLibrary path @+0x3e8.
11 vectors.

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
