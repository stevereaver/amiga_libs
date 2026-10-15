---
type: Library
title: sz_aio_ahi.library 0.2
description: >-
  sz_aio_ahi V0.2  09.03.2000  by Rainer Muller — AHI audio output library (ahi.device/
gadtools.library deps); single CODE hunk, 7 vectors.
files:
  - source/sz_aio_ahi_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# sz_aio_ahi.library 0.2

Single CODE hunk (3264B).  `moveq #-1; rts` stub, Resident@+4
(AUTOINIT v0), InitTable@+0x1e (datasize 0x430, functab->+0xb3e,
datatab->+0x2e, initfn->+0x4e).

- name 'sz_aio_ahi.library'@+0x254,
  idstring 'sz_aio_ahi V0.2  09.03.2000  by Rainer Muller'@+0x267
- functab@+0xc2e: 7 absolute entries (open/close/expunge/
  reserved + 3 user vectors) + ffffffff
- opens dos/intuition/graphics at init; user vectors open
  ahi.device and gadtools.library

## Build

`sz_aio_ahi_h0.s` verbatim; head data region raw through
+0x60.  `fixup.py` splices the 19-entry RELOC32 tail.
Byte-identical (md5 e9e27e88aec8e111635afa43036f64ec).

## Runtime

`work/oracle.py`: init, all 7 vectors, open x2, close x2
(deferred + real expunge).  Identical original vs rebuild.
