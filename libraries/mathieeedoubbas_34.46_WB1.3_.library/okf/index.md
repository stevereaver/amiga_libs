---
bundle: mathieeedoubbas_34.46
status: complete
updated: 2026-10-15
---
# mathieeedoubbas.library 34.46

IEEE double-precision math base library (WB1.3 era,
28 May 1988) — SAS/C build. 3 hunks: CODE 0x45f longs
(+4B body overrun) + two empty linker-artifact hunks.
COLDSTART (resident flags 0x01, init is CODE): initfn
probes MathIEEE.resource, selects 1 of 3 word-offset
functabs by AttnFlags bit4 + resource presence, calls
MakeLibrary itself. 16 vectors.

- `structures/layout.md` — hunk map, resident, functabs
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
