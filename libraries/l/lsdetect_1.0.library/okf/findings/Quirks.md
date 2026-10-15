---
type: Finding
title: Quirks
description: Oddities found in the shipped binary.
timestamp: 2026-10-10T20:40:00Z
---

# Quirks

- All four `OpenLibrary` results are unchecked at init — the lib
  "works" with zero support libraries and just degrades.
- `LSBorrowScreen` calls `GetRGB4` on the longword at
  `colormap+4` (the `ColorTable` pointer), not on the ColorMap
  pointer — recorded verbatim, likely reads back a different
  value than intended.
- The language byte and flag byte occupy base+34/+35, just past
  `lib_OpenCnt` — the "DELEXP" flag is private, `lib_Flags` is
  never touched.
- IdString is stored behind a stray NUL byte (`IDSTRING+1`).
- Language result 0/1/2 maps to Italian/English/German per the
  prompt ordering (F1=0, F2=1, F3=2) and the name-prefix checks.
- The interactive fallback reads raw console bytes looking for
  `0x9b` (CSI) followed by '0'..'2' — i.e., it expects raw F-key
  sequences rather than cooked line input.
