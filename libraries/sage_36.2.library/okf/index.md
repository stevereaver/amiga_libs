---
bundle: sage_36.2.library
status: complete
updated: 2026-10-15
---
# SAGE.library 36.2 (1 May 1992)

SAGE graphics/utility library (HiSoft SAGE debugger-related).
2 hunks: CODE 3948B + DATA 300B. AUTOINIT resident@h0+0x1e
ver 36; InitTable lives in the DATA hunk at h1+4 with a
functab pointing back into h0 — inverted cross-hunk layout.
10 vectors.

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
