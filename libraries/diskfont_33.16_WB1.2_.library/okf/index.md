---
bundle: diskfont_33.16(WB1.2)
status: complete
updated: 2026-10-15
---
# diskfont 33.16 (10 Feb 1986, WB1.2)

Commodore disk-based font library. rt_Flags=0 plain resident —
init@h0+0x50 builds args and calls `exec.MakeLibrary` itself
(a0=functab@h0+0x15e, a1=datatab, a2=initfn@h0+0x80, dsize=0x38),
then AddLibrary. 13 hunks — per-module WB1.x link style.

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
