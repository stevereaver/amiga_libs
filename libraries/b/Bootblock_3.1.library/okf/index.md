---
type: Library
title: Bootblock.library 3.1 (24.06.93)
description: >-
  Bootblock.library 3.1 — 12-vector AUTOINIT library in a 4-hunk
  layout with cross-hunk relocations everywhere (functab in hunk1,
  main code in hunk3).
files:
  - source/Bootblock_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# Bootblock.library 3.1

Four hunks:

- hunk0 CODE 476B — `moveq #-1; rts` stub + Resident@+4 +
  InitTable@+0x1e (dsz 0x5e, ftab->h1+0x3a, dtab=0,
  initfn->h0+0x2e) + support code
- hunk1 CODE 112B — 'Bootblock.library', idstring
  'Bootblock.library 3.1 (24.06.93)' CRLF, then the 12-long
  absolute functab at +0x3a (4 entries ->h0, 8 ->h3) + ffffffff
- hunk2 DATA 96B — all-zero global space (referenced by h0 and
  h3 code operands)
- hunk3 CODE 2240B — main implementation: opens
  dos/expansion/trackdisk, does bootblock read/write work

## Build

`source/Bootblock_h0.s` emits .text = h0+h3 merged and .data =
h1+h2 merged; `fixup.py` splits both blobs back into the 4-hunk
layout and splices all original RELOC32 groups (h0->h0/h1/h2/h3,
h1->h0/h3, h3->h2).  Byte-identical (md5
99f5efb28c3b2391cb39c0847965007a).

## Runtime

`work/oracle.py` loads all 4 hunks, applies cross-hunk relocs,
runs initfn (exec init + openlib dos.library), installs all 12
vectors, exercises open x2 / all LVOs / close x2 / expunge.
Identical logs between original and rebuild.
