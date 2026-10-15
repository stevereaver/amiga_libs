---
bundle: muilowlevel_19.9.library
status: complete
updated: 2026-10-15
---
# muilowlevel.library 19.9 (12.97) — Stefan Stuntz / MUI

MUI low-level input helper library. 2 hunks: CODE 3808B + BSS 16B.
COLDSTART resident (flags 0, ver 19), initfn does its own
MakeLibrary + AddLibrary. 33 vectors — dispatcher-routed helper
functions for MUI input/event handling.

- `structures/layout.md` — hunk map, resident, functab
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
