---
type: Library
title: amigametaformat.library 6.0
description: >-
  AmigaMetaFormat AMF(tm) 6.0 — metafile-format dispatcher that
  loads AMF/* driver sub-libraries; single CODE hunk, 7 vectors.
files:
  - source/amigametaformat_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# amigametaformat.library 6.0

Single CODE hunk (3264B).  `moveq #-1; rts` stub, Resident@+4
(AUTOINIT v6), InitTable@+0x1e (datasize 0x430, functab->+0xc2e,
datatab->+0x2e, initfn->+0x44e).

- name 'amigametaformat.library'@+0x24e,
  idstring 'AmigaMetaFormat AMF(tm) 6.0'@+0x266
- functab@+0xc2e: 7 absolute entries (open/close/expunge/
  reserved + 3 user vectors) + ffffffff
- opens dos/intuition/graphics at init; strings reference 12
  AMF/*.driver sub-modules (jmf/wmf/ai/dr2d/hpgl/ww/cgm/gem/
  eps/strip/file)

## Build

`amigametaformat_h0.s` verbatim; head data region raw through
+0x60.  `fixup.py` splices the 19-entry RELOC32 tail.
Byte-identical (md5 cd5a51d859b690336a31e4eddd5adfdd).

## Runtime

`work/oracle.py`: init, all 7 vectors, open x2, close x2
(deferred + real expunge).  Identical original vs rebuild.
