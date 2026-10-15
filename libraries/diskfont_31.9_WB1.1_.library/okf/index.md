---
bundle: diskfont_31.9(WB1.1)
status: complete
updated: 2026-10-15
---
# diskfont 31.9 (23 Nov 1985, WB1.1)

Commodore disk-based font library. rt_Flags=0 plain resident —
init@h0+0x50 builds args and calls `exec.MakeLibrary` itself
(a0=functab@h0+0x15e, a1=datatab, a2=initfn@h0+0x80, dsize=0x38),
then AddLibrary. 13 hunks — per-module WB1.x link style.

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
