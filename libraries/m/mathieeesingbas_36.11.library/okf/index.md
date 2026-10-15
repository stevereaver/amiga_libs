---
bundle: mathieeesingbas_36.11.library
status: complete
updated: 2026-10-15
---
# mathieeesingbas 36.11 (28 Sep 1988)

Commodore single-precision IEEE basic math library (WB1.3-era).
COLDSTART (non-AUTOINIT) resident; init code calls
`exec.MakeLibrary` itself after probing `MathIEEE.resource` and the
AttnFlags FPU bit, selecting one of three word-offset function
tables. 16 vectors.

- `structures/layout.md` — hunk map, resident, functab variants
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
