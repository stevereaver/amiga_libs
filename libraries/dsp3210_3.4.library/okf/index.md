---
bundle: dsp3210_3.4.library
status: complete
updated: 2026-10-15
---
# dsp3210.library 3.4

AT&T DSP3210 d32 object-file loader/relocator library.
Single CODE hunk (4260B). COLDSTART resident@h0+4 ver 3;
rt_Init@+0x9c does MakeLibrary + AddLibrary. 14 vectors —
absolute-long functab (unlike the 5.0/6.0 word-offset tables).

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
