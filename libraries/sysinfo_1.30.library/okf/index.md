---
type: Library
title: sysinfo.library 1.30
description: >-
  $VER: SysInfo.library 1.30 (22.11.95) — 'Executive_server'
  system-info lib; 3 hunks, 16 vectors, cross-hunk resident.
files:
  - source/sysinfo_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# sysinfo.library 1.30

Three hunks: CODE 3148B + DATA 28B (InitTable) + CODE 96B
(functab + strings).  Resident@h0+4 (AUTOINIT v1); rt_Name and
rt_IdString relocate into hunk2 (+0x44 'SysInfo.library',
+0x54 'Version 1.0'), rt_Init relocates into hunk1+4.

- InitTable@h1+4: dsz 0x4c, functab->h2+0 (16 absolute longs +
  ffffffff), dtab=0, initfn->h0+0x20
- h1+0x14 holds a second relocated pointer (->h0+0x206)
- idstring in h0: '$VER: SysInfo.library 1.30 (22.11.95)'@+0x202
  plus 'Executive_server'@+0x22c

## Build

`sysinfo_h0.s` verbatim; hunk1+hunk2 emitted as one .data blob;
`fixup.py` re-splits into the original 3-hunk header and splices
all three reloc tails (2/3/4-entry groups for h0, 3-entry h1,
16-entry h2->h0).  Byte-identical (md5 c6d1739bed4847b9bfc9e0a53684e1ba).

## Runtime

`work/oracle.py`: init, 16 vectors, open x2, close x2,
deferred+real expunge.  Identical original vs rebuild.
