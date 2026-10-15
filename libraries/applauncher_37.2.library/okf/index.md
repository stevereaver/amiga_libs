---
bundle: applauncher_37.2.library
status: complete
updated: 2026-10-15
---
# applauncher 37.02 (04.10.94)

SAS/C-built application launcher library. Plain resident
(flags=0): rt_Init@h0+0x20 jmps to a C runtime bootstrap at +0x64
which allocates the library via MakeLibrary(21 vectors,
dsize 0x22) with a functab living in the a4-relative DATA hunk.

- `structures/layout.md` — hunk map, resident, a4-frame model
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
