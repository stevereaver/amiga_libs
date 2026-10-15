---
bundle: hgrexxsupport__18.7.94_.library
status: complete
updated: 2026-10-15
---
# hgrexxsupport.library (18.7.94)

Hartmut Goebel's ARexx host-support library. 3 hunks:
h0 CODE 0x478 longs (resident+InitTable+code), h1 DATA
0x1b longs (dep strings + functab ptrs + InitStruct),
h2 BSS 4 longs. AUTOINIT ver 1. 4 real vectors (+1 NULL).

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks (26B resident, extra field)
