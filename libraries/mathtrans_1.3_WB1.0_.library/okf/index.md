---
type: Library
title: mathtrans.library 1.3 (WB1.0)
description: >-
  'mathtrans 1.3 (10 Sep 1985)' — original Workbench 1.0
  transcendental-math library built on the MC68343 FP firmware
  (hunk13); 17 hunks; 18 vectors split across hunks 0+1.
files:
  - source/mathtrans_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# mathtrans.library 1.3 (WB1.0)

Seventeen hunks — fifteen CODE bodies (hunks 0-13,15; hunk14
is zero-length), one empty DATA hunk (h16).  Per-function
linker layout typical of 1985 builds.

- Resident@h0+0: fl=0x81 AUTOINIT v1, name->0x1a
  'mathtrans.library', id->0x2c 'mathtrans 1.3 (10 Sep 1985)',
  init->InitTable@0x4c
- InitTable@0x4c: dsz 0x22, functab->h0+0x7a, datatab->h0+0x64,
  initfn->h0+0x5c
- functab@0x7a (2-aligned!): 18 absolute longs + ffffffff —
  first 4 ->h0 (Open/Close/Expunge/reserved), next 14 ->h1
  (math routines living in hunk1)
- hunk13 carries the 'MC68343 FLOATING POINT FIRMWARE
  (C) COPYRIGHT 1981 BY MO[TOROLA]' string
- deps: mathffp.library
- extensive cross-hunk relocs: h0->h1 (14 functab slots),
  h1->{h2..h12} dispatch, h15->h0

## Build

`mathtrans_h0.s` verbatim .byte streams per hunk into a single
.text (hunks are mostly MC68343 firmware + FP glue with heavy
inline data); `fixup.py` asserts the merged body then re-emits
the original 17-hunk header + all tails.  Byte-identical
(md5 257f84d4760156e1aa884a5a8a4c355f).

## Runtime

`work/oracle.py`: init, all 18 vectors, open x2, close x2
(opencnt underflow), expunge.  Identical original vs rebuild.
