---
type: Library
title: goldenbyte.library 1.21 (24.02.97, GOLDEN BYTE)
description: >-
  Golden Byte 1.21 — GUI/requester toolkit library; single CODE
  hunk, 25 vectors, opens 10 system libraries at init.
files:
  - source/goldenbyte_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# goldenbyte.library 1.21

Single CODE hunk (3132B).  `moveq #-1; rts` stub at +0,
Resident@+4 (AUTOINIT v1), InitTable@+0x50 (datasize 0x62,
functab->+0x60 absolute, datatab=0, initfn->+0xc8).

- name 'goldenbyte.library'@+0x1e, idstring
  'GOLDEN BYTE 1.21 (24.02.97)' CRLF-terminated @+0x31
- functab@+0x60: 25 absolute entries + ffffffff
- initfn (h0+0xc8) opens intuition, graphics, dos, utility,
  workbench, layers, reqtools, commodities, diskfont and
  icon.library — a 10-library GUI dependency list

## Build

`goldenbyte_h0.s` verbatim; head data region (resident header +
strings + InitTable + functab) emitted raw through +0xc0.
`fixup.py` splices the original 47-entry RELOC32 tail
(mixed-order group).  Byte-identical (md5 1880ec27d73ef046cbd1e93699b28ec6).

## Runtime

`work/oracle.py`: init, all 25 vectors, open x2, close x2
(deferred + real expunge).  Identical original vs rebuild.
