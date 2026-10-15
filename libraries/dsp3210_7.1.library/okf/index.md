---
bundle: dsp3210_7.1.library
status: complete
updated: 2026-10-15
---
# dsp3210.library 7.1 (12.12.2021)

DSP3210 loader library by Thomas Winischhofer (A10001986).
Single CODE hunk (0x478 longs). COLDSTART resident
(flags 0, ver 7) — module entry does MakeLibrary +
AddLibrary itself. 15 word-offset vectors. New container
cookie 0x00fc2011. Near-identical build to 7.0 sibling.

- `structures/layout.md` — hunk map, resident, container
- `functions/vectors.md` — LVO table + D32 blob protocol
- `findings/defects.md` — 7.0->7.1 deltas, quirks
