---
type: Library
title: utilities.library 1.2
description: >-
  $VER: utilities.library 1.2 (6.06.01) — Polish-language
  string/number helper library; resident embedded at the end of
  the DATA hunk; 26 vectors.
files:
  - source/utilities_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# utilities.library 1.2

Two hunks: CODE 2244B + DATA 1012B.  Resident@h1+0x3bc (AUTOINIT
v3), InitTable@h1+0x374 (dsz 0x26, functab->h1+0x308, dtab=0,
initfn->h0+0x70c).

- name 'utilities.library'@h1+0x384, idstring
  '$VER: utilities.library 1.2 (6.06.01)'@h1+0x396
- functab@h1+0x308: 26 absolute longs -> hunk0 + ffffffff
- DATA hunk is a Polish message-string table ('Sprawdzenie, czy
  %ld...', 'Duplikacja lancucha', etc.) plus trailing dep names
  dos.library/utility.library
- cross-hunk relocs both ways (h0->h1 operands, h1->h0 functab)

## Build

`utilities_h0.s` verbatim (.text) + raw hunk1 .data; `fixup.py`
splices both reloc tails (27-entry h0->h1 + 32-entry h1
mixed).  Byte-identical (md5 6583e4621b74fc987428889c5c70be6d).

## Runtime

`work/oracle.py`: init, all 26 vectors, open x2, close x2,
deferred+real expunge.  Identical original vs rebuild.
