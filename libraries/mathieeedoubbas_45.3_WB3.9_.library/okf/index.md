---
bundle: mathieeedoubbas_45.3(WB3.9)
status: complete
updated: 2026-10-15
---
# mathieeedoubbas 45.3 (23.11.2000, WB3.9)

Commodore double-precision IEEE basic math library — the WB3.9
build. COLDSTART (non-AUTOINIT, flags 0x01); init code probes
`fpsp.resource` + AttnFlags bit4 and selects one of three
word-offset function tables, then calls MakeLibrary+AddLibrary
itself. 16 vectors.

- `structures/layout.md` — hunk map, resident, functab variants
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
