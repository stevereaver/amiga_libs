---
type: Library
title: newfmt.library 4.2
description: >-
  'newfmt 4.2 (10.1.98)' — printf-style formatting library;
  4-hunk build with the InitTable in hunk1 and
  functab+strings in hunk3; 17 vectors.
files:
  - source/newfmt_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# newfmt.library 4.2

Four hunks: CODE 3008B + DATA 16B (InitTable) + CODE 72B +
DATA 180B (functab + strings).

- Resident@h0+4: AUTOINIT fl=0x80 v4 ty=9, name->h3 'newfmt.
  library', id->h3 'newfmt 4.2 (10.1.98)', init->h1 InitTable
- InitTable@h1+0: dsz 0x104, functab->h3+0x28, dtab=0,
  initfn->h0+0x20 (subqw #8,sp prologue)
- functab@h3+0x28: 17 absolute longs -> h0 + ffffffff; a
  second ->h0 pointer table follows at h3+0x70..0x8c
- h2 is a 72B aux CODE block (tstb/branch routines)
- deps: utility, dos, intuition; error template
  "Can't open version %ld of "; 'pcon:10/10/320/80/'
  debug-output device string; '*NULL POINTER*'

## Build

`newfmt_h0.s` verbatim .text (h0) + one .data blob carrying
h1+h2+h3; `fixup.py` asserts body equality then re-splits into
the original's 4 hunks and splices all RELOC32 tails.
Byte-identical (md5 2bc646daff2f95e0f5ca5315050211e1).

## Runtime

`work/oracle.py`: init performs an enormous ~578.9M-access
unmapped-memory walk (reproduced exactly; counted via
set_invalid_func), then OpenLibrary(dos).  All 17 vectors,
open x2, close x2, expunge — identical original vs rebuild.
