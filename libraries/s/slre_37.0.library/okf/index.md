---
bundle: slre_37.0.library
status: complete
updated: 2026-10-15
---
# slre.library 37.0

Small regular-expression library (single public API function,
register-args ABI). 4-hunk file with an unusual split:
h0 CODE (resident + all code), h1 DATA (268-byte regex
char-class struct copied into the library base by init),
h2 DATA (4 longs = the AUTOINIT InitTable), h3 CODE
(5-entry function table + name/id strings). Each hunk has
its own RELOC32+END tail with cross-hunk references in
both directions. RomTag packed at h0+4 behind a
`moveq #0,d0;rts` guard. AUTOINIT, ver 37, NT_LIBRARY,
pri 0. 5 vectors: Open/Close/Expunge/dummy-stub/worker.

- `structures/layout.md` — hunk map, resident, InitTable, libbase
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
