---
bundle: diskfont_1.3_WB1.0_.library
status: complete
updated: 2026-10-15
---
# diskfont.library 1.3 (WB1.0, 1985/86)

Earliest shipped diskfont.library. Same 13-hunk per-function
link layout as the 31.9/33.16 family. Plain COLDSTART resident —
rt_Init@h0+0x4c runs MakeLibrary+AddLibrary manually; initfn
@h0+0x7a opens dos.library + graphics.library. 6 vectors.

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
