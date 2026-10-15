---
type: Findings
title: dsp3210 3.0 quirks
---

# Findings / quirks

- Non-AUTOINIT: module entry itself calls MakeLibrary
  (-84, dsize 46) + AddLibrary (-396), then exec calls
  libInit separately.
- -54/-66 mask the arg pointer with 0x4ff00 under stubs —
  pointer arithmetic quirk reproduced verbatim.
- Descending-order relocation tail (0xc18..0x6).
