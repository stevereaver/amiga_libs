---
type: Library
title: fwpenpal.library 3.0
description: >-
  'fwpenpal 3.0 (6-Aug-93)' — Falcon/Warp penpal (expansion)
  library; 2 hunks with REVERSED tags (hunk0 is DATA-tagged
  code, hunk1 is CODE); 5 vectors.
files:
  - source/fwpenpal_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# fwpenpal.library 3.0

Two hunks with swapped tags: hunk0 is tag 0x3ea (DATA) 3200B
but carries all the resident code; hunk1 is tag 0x3e9 (CODE)
196B of tail-jumped routines.

- h0: `moveq#0;rts` stub, 'fwpenpal.library'@4,
  'fwpenpal 3.0 (6-Aug-93)\r\n'@0x16, code 0x32..0xc2f,
  `jmp h1+0` trampoline@0xc30, functab@0xc38,
  InitTable@0xc50 (dsz 0x22, ftab->h0+0xc38, initfn->h0+0xbc),
  Resident@0xc60 (AUTOINIT v3, name->4, id->0x16)
- h1: 196B of small code routines reached via the h0
  trampoline
- functab: 5 absolute longs -> h0 + ffffffff:
  -6 0x32 Open / -12 0x9a Close / -18 0x4a Expunge /
  -24 h0+0 stub / -30 0x0fc

## Build

`fwpenpal_h0.s` verbatim (.text = orig DATA hunk, .data = orig
CODE hunk); `fixup.py` pairs orig hunk tags (DATA/CODE) with
the linked sections and splices the 14-entry RELOC32 tail.
Byte-identical (md5 e244565e6b6544e553b9a8c4158d7793).

## Runtime

`work/oracle.py`: init, all 5 vectors, open x2 (returns the
lib base, not a fresh handle), close x2 (opencnt underflows to
0xffff), expunge.  Identical original vs rebuild.
