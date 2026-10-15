---
type: Library
title: rexxidentify.library 1.16
description: >-
  rexxidentify.library 1.16 (12.11.2022) — ARexx support for
  identify.library (Richard 'Shred' Koerber, LGPL v3).
  Base-relative build: DREL16 relocs, resident+InitTable inside
  CODE hunk; 5 vectors, single ARexx command dispatcher at -30.
files:
  - source/rexxidentify_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# rexxidentify.library 1.16

Two hunks: CODE 0x365 longs (0xd94 bytes; alloc size 0x369 — the
last 4 longwords are in-hunk variables) + BSS 0x80 longs (0x200).
Resident@h0+4 (AUTOINIT), InitTable@h0+0x100 (dsz 0x2c,
functab->h0+0x110, dtab->h0+0x128, initfn->h0+0x148).

- name 'rexxidentify.library'@h0+0x1e, idstring
  'rexxidentify.library 1.16 (12.11.2022)\r\n'@h0+0x33
- functab@h0+0x110: 5 absolute longs -> hunk0 + ffffffff
- relocs are DREL16 (0x3f7): word count/hunkno/offset entries that
  patch longword fields holding hunk-relative offsets; groups
  h0->h0 (32 slots) and h0->h1 (6 slots); trailing pad word before
  HUNK_END when the word table ends odd
- deps: rexxsyslib.library v33, expansion.library v36,
  commodities.library v36, identify.library v41
- init enumerates all ConfigDevs (expansion FindConfigDev -72)
  into the BSS hunk and stores the count at h0+0xda2

## Build

`rexxidentify_h0.s` verbatim .text (+ .bss 0x200); `fixup.py`
copies header/DREL16 tail verbatim after asserting hunk bodies
match.  Byte-identical (md5 27464eaffbea19f582c36ec84f2394f1).

## Runtime

`work/oracle.py`: init, all 5 vectors, open x2, RexxMsg command
dispatch (ID_RELEASE/NUMBOARDS/EXPANSION/HARDWARE/ALERT/COUNTCX/
bogus), close x2 (deferred expunge fires inside second close),
expunge.  Identical original vs rebuild.
