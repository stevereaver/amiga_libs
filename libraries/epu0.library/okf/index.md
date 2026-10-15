---
bundle: epu0.library
status: complete
updated: 2026-10-15
---
# epu0.library

EPU patch/utility library — 7-hunk multi-segment build. Packed
AUTOINIT resident in h0; InitTable@h0+0x56; 6 vectors.
initfn opens dos.library + intuition.library.

- `structures/layout.md` — hunk map, resident, InitTable
- `functions/vectors.md` — LVO table
- `findings/defects.md` — quirks
