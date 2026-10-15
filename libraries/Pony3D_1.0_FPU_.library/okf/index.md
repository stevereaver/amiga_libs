---
type: Library
title: Pony3D.library 1.0 (FPU)
description: >-
  Pony3D.library 1.0 (13-Feb-2000), ASM-One 1.25 build by Tomasz
  "Pony van Deathface" — 3D helper lib; 3 hunks, 8 vectors,
  resident embedded mid-hunk0.
files:
  - source/pony3dfpu_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# Pony3D.library 1.0 (FPU)

Three hunks: CODE 632B + CODE 684B + DATA 2252B.

- Resident embedded at h0+0xca (AUTOINIT v1), name->h0+0xe6
  'Pony3D.library', idstring->h0+0xf6
  ' Pony3D.library 1.0 (13-Feb-2000).' + ASM-One credit
- InitTable@h0+0x172: dsz 0x2a, functab->h0+0x182 (8 absolute
  longs + ffffffff: 4 ->h0, 4 ->h1), datatab->h0+0x1a6
  (InitStruct), initfn->h0+0x1c6
- hunk2 DATA holds dos.library/reqtools.library deps + 'OKAY'
  + '$VER: Pony3D.library 1.0 (13.02.2000)'@+0x8a6

## Build

`pony3d_h0.s` verbatim: hunk0+hunk1 bodies merged into .text,
hunk2 into .data.  `fixup.py` re-splits the CODE blob and
restores the original 3-hunk header + all reloc tails.
Byte-identical (md5 12f5e4055d9c626e97ab6b20ae2e99e5).

## Runtime

`work/oracle.py`: init (CopyMem/InitStruct-ish sequence), all
8 vectors, open x2, close x2, deferred+real expunge.
Identical original vs rebuild.
