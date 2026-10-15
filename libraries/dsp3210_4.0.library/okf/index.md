---
bundle: dsp3210_4.0.library
status: complete
updated: 2026-10-15
---
# dsp3210.library 4.0 (15.7.2021, Thomas Winischhofer)

AT&T DSP3210 development-support library ('DSPCOMPAT' flag,
d32 module loader). Single CODE hunk; plain COLDSTART resident;
rt_Init@+0x9c runs MakeLibrary+AddLibrary manually. 14 vectors.

- `structures/layout.md` — hunk map, resident, functab
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
