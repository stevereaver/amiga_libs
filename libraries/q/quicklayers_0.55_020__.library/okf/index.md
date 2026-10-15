---
bundle: quicklayers_0.55_020__.library
status: complete
updated: 2026-10-15
---
# quicklayers.library 0.55 (06.12.2005) 68020+

Layers.library accelerator/patcher by Sante Nocciolino.
2 CODE hunks: h0 0x2e8B (resident + 4-vector shim lib +
patch engine), h1 0x3e5B (replacement routines). AUTOINIT|
flags 0x81, ver 0. initfn copies a resident module into RAM
and rewrites its jump table via a 12-entry patch table.

- `structures/layout.md` — hunk map, resident, patch table
- `functions/vectors.md` — LVO table + init mechanism
- `findings/defects.md` — quirks
