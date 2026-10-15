---
type: Library
title: newicon.library 45.0 (WB3.9)
description: >-
  'newicon.library 45.0 (27.10.00) emulation (C) 2000 by S[tefan
  B.]' — NewIcons emulation library; 2 hunks with DREL16
  relocations; 13 vectors.
files:
  - source/newicon_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# newicon.library 45.0 (WB3.9)

Two hunks: CODE 3200B + DATA 236B.  Both tails use DREL16
(0x3f7) word-offset relocation groups.

- Resident@h1+0xa0: AUTOINIT fl=0x80 v45 ty=9 pri=0,
  name->h1+0x38 'newicon.library',
  id->h1+0x48 'newicon.library 45.0 (27.10.00) emulation
  (C) 2000 by S...', init->h1+0x90
- InitTable@h1+0x90: dsz 0x32, functab->h1+0x00, dtab=0,
  initfn->h0+0x0c
- functab@h1+0x00: 13 absolute longs -> hunk0 + ffffffff
- h1 strings: 'NewIconEmu' tooltype template
  'NI=NEWICONS/S,OPT=OPTIMIZE/S,DP=DROPPLANAR/S' in h0,
  '*** DON'T EDIT THE FOLLOWING LINES!! ***' + 'IM1='/IM2='
  marker strings in h1 tail
- deps in h0: icon.library, dos.library

## Build

`newicon_h0.s` verbatim .text + raw hunk1 .data; `fixup.py`
splices the DREL16 tails verbatim (word-group walker).
Byte-identical (md5 below).

## Runtime

`work/oracle.py`: init (frees a private 0xa2B block), all 13
vectors, open x2, close x2, deferred+real expunge.  Identical
original vs rebuild.
