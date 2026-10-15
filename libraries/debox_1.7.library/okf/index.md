---
type: Library
title: debox.library 1.7
description: >-
  debox 1.7 (01 OCT 90) by William A. Ware / R. K. Von
  Wolfsheild, Silent Software — 'debox' depacker library;
  non-AUTOINIT single CODE hunk, initfn builds the library via
  exec MakeLibrary; 22 vectors.
files:
  - source/debox_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# debox.library 1.7

Single CODE hunk (3284B).  `bra.w` stub + `moveq#0;rts` @0,
Resident@+8 (flags=0 — non-AUTOINIT, rt_Init->+0x1e8 is the
init routine).

- name 'debox.library'@+0x22, idstring 'debox 1.7 (01 OCT 90)'
  CRLF-terminated @+0x30; copyright banner strings to +0xee
- functab@+0xfc: 22 absolute-long entries + ffffffff
- initfn@+0x1e8: opens graphics.library v34, calls exec
  MakeLibrary(-84) with functab@+0xfc / InitStruct@+0x198 /
  dsize 0x6e, stashes execbase@lib+34, gfxbase@lib+38,
  seglist@lib+42, then AddLibrary(-396) — manual library
  construction instead of AUTOINIT InitTable
- vectors include XOR-decrypt loops (eor.b/.l streams @0x8d8)
  and bitstream depack helpers — 'debox' screen/data unpacker

## Build

`debox_h0.s` verbatim; head data (resident + strings + functab)
raw through +0x158.  `fixup.py` splices the 41-entry RELOC32
tail.  Byte-identical (md5 a99419575dfd72c298cd4f212e5d3a5c).

## Runtime

`work/oracle.py`: non-AUTOINIT init via MakeLibrary trap,
22 vectors, open x2, close x2, deferred+real expunge —
identical original vs rebuild.
