---
type: Library
title: newicon.library 44.3
description: >-
  'newicon.library 44.3' — NewIcons library (pre-45 build);
  3 hunks (CODE + DATA + 12B BSS), DREL16 relocations,
  13 vectors.
files:
  - source/newicon_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# newicon.library 44.3

Three hunks: CODE 3200B + DATA 236B + BSS 12B.  Both tails
use DREL16 (0x3f7) word-offset relocations with a bare
zero-word terminator + alignment pad.

- Resident@h1+0xa0: AUTOINIT fl=0x80 v44 ty=9 pri=0,
  name->h1+0x38 'newicon.library', id->h1+0x48
  'newicon.library 44.3 ...', init->h1+0x90
- InitTable@h1+0x90: dsz 0x32, functab->h1+0x00, initfn->
  h0+0x0c
- functab@h1+0x00: 13 absolute longs -> hunk0 + ffffffff
- deps in h0: icon.library, dos.library
- sibling of newicon 45.0 (WB3.9) — same DATA-hunk layout

## Build

`newicon_h0.s` verbatim .text + .data = orig DATA hunk + 12B
zero placeholder for the BSS hunk; `fixup.py` emits the
original 3-hunk header/tags (incl. body-less BSS) and splices
the DREL16 tails (word-group walker with 2-byte terminator).
Byte-identical (md5 a91df5af09fecd0ce9dd926b837b90f1).

## Runtime

`work/oracle.py`: init frees a 0xa2B scratch block, all 13
vectors, open x2, close x2, deferred+real expunge.
Identical original vs rebuild.
