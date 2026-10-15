---
type: Library
title: xpkNUKE.library 1.1
description: >-
  xpkNUKE 1.1 — XPK 'NUKE' compression codec sub-library ($VER: NUKE 1.1 (Nov  2 1992));
  two hunks (CODE+DATA), 10 vectors, Huffman-style packer.
files:
  - source/xpkNUKE_h0.s
  - source/xpkNUKE_h1.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# xpkNUKE.library 1.1

Two hunks: CODE 0xaf4B + DATA 0x140B.  RomTag at code+4,
rt_Init -> data+4 -> InitTable (dataSize=0x156, funcTab->
code+0xaa4, dataTab=0, initFn->code+0x20).  Absolute-long
functab: 10 vectors (-6..-60) + -1 terminator.

- initFn copies the DATA hunk into lib+0x3a and self-relocates
  8 internal pointers (table at data+0x120, count at +0x11c);
  seglist at lib+0x22.
- Codec: NUKE packer — per-stream allocmem of an 84B context +
  0x20000 + 0x10000 work tables; pack to caller buffer, unpack
  reads xsp+16 as expected output length.

## Build

`xpkNUKE_h0.s`/`xpkNUKE_h1.s` verbatim; `fixup.py` splices the
original RELOC32 tails (16+2 slots h0, 2 h1).  Byte-identical
(md5 bb4257fa0250c2259f600754808843da).

## Runtime

`work/oracle.py`: init, all 10 vectors, real pack->unpack
round-trips on 12 payload shapes (80B repeats, 30kB runs, 8kB
random, mixed), chained packs, realloc, alloc-fail, garbage
unpack — identical original vs rebuild.
