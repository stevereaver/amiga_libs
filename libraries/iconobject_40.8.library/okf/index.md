---
type: Library
title: iconobject.library 40.8 (Aug 12 2012, SAS/C 6.58, Scalos Team)
description: >-
  Scalos iconobject.library 40.8 — icon .info datatype object
  library; SAS/C build with the Resident embedded in the DATA
  hunk and a4-relative code.
files:
  - source/iconobject_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# iconobject.library 40.8

Two hunks: hunk0 CODE 2428B (pure code), hunk1 DATA 460B.

- DATA hunk strings: 'iconobject.library', '$VER:
  iconobject.library 40.8 Aug 12 2012  (SAS/C 6.58)',
  '1999-2012 The Scalos Team', dos/intuition/utility.library,
  'Scalos:IconDatatypes/' paths, '.info' suffixes
- DATA+0x15c: InitTable — datasize 0x6c, functab->DATA+0x12c,
  datatab=0, initfn->CODE+0x75e
- DATA+0x12c: 11-entry absolute functab + 0xffffffff
- DATA+0x16c: Resident (AUTOINIT v40) embedded mid-DATA-hunk

## Build

Verbatim `iconobject_h0.s` (hunk0 code, hunk1 as .data blob).
`fixup.py` restores the 2-hunk header and splices the original
RELOC32 tails (h0->h1 69-entry descending + h0->h0, h1->h0
functab, h1->h1 resident pointers).  Byte-identical (md5
5ff3b5b3e306951223322557f64139a2).

## Runtime

`work/oracle.py` finds the embedded Resident, runs initfn
(opens dos/intuition/utility v39, creates msg port; under stubs
the port creation fails and the lib self-frees via
exec Remove/FreeMem), all 11 vectors, deferred + real expunge.
Identical logs original vs rebuild.
