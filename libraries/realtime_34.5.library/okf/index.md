---
bundle: realtime_34.5.library
status: complete
updated: 2026-10-15
---
# realtime.library 34.5

Real-time library (CIA timer interrupt scheduling —
ciaa/ciab.resource + utility.library deps). 1 CODE hunk
(0x45a longs, clean). AUTOINIT resident@h0+4 ver 34,
InitTable@h0+0x4a, 19 installed vectors (20-entry
abs-long functab, first entry 0).

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table + CIA semantics
- `findings/defects.md` — quirks
