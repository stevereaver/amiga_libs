---
type: Structures
title: mathtrans 1.3 layout
---

# Layout

- datasize 0x22; datatab@h0+0x64 initializes node fields.
- 15 CODE hunks: h0 lib glue + h1 main math + h2..h12 helper
  routines + h13 MC68343 firmware + h15 tail stub; h14/h16
  are zero-length hunks (linker artifacts preserved).
- Cross-hunk functab: slots relocate to h0 for LVOs
  -6..-24 and to h1 for -30..-108.
