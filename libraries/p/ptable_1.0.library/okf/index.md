---
bundle: ptable_1.0.library
status: complete
updated: 2026-10-15
---
# ptable.library 1.0 (16.05.2026) [68000]

RDB partition-table helper library. One CODE hunk (3652B), AUTOINIT
Resident at +4. Scans Amiga Rigid Disk Block structures — the code
contains RDSK/FSHD/PART/LSEG magic probes and progress strings
(`[RDB] scan`, `[RDB] found RDSK`, `[RDB] +fs`, `[RDB] +boot`,
`[RDB] +dos`, `[RDB] skip`, `[RDB] done`). Depends on
`NuExpansion.library`, `dos.library`, and `FileSystem.resource`;
vectors open `expansion.library`.

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
