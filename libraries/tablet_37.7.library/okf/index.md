---
type: Library
title: tablet.library 37.7
description: >-
  tablet.library 37.7 (28.04.93) — TriMedia graphics-tablet driver
  support (AccuPoint/Wacom era; used by DeluxePaint 4.5 tablet
  pressure).  AUTOINIT, absolute-long functab, RELOC32 relocs;
  InitTable lives in the DATA hunk.  Installs a "TabletPatch" port
  plus a private input.device handler that hooks intuition.library
  at version-specific offsets.
files:
  - source/tablet_h0.s
  - source/fixup.py
  - source/Makefile
  - work/oracle.py
---

# tablet.library 37.7

Two hunks: CODE0 0x377 longs (0xddc bytes) + DATA1 0x33 longs
(0xcc).  Resident@h0+4 (AUTOINIT, rt_Init -> h1+4); InitTable@h1+4
{dsz 0x1a2, functab -> h0+0xca4, dtab NULL, initfn -> h0+0x20}.
Leading h1 longword at +0 is an unused zero slot before the
InitTable.

- stub `moveq #0,d0;rts` @h0+0; Resident @h0+4 (flags 0x80
  AUTOINIT, rt_Version 33!, type NT_LIBRARY, name -> h0+0xcc8
  'tablet.library', id -> h0+0xcd8 'tablet.library 37.7
  (28.04.93)')
- functab@h0+0xca4: 8 absolute longs -> hunk0 (entry 3 is a 0
  hole for the reserved -24 slot) + 0xffffffff
- RELOC32 (0x3ec) tails only: h0 groups {14 x h0->h0:
  6 resident/code ptrs + 8 functab slots; 2 x h0->h1: rt_Init and
  one imm32 store}; h1 group {2 x h1->h0: InitTable functab +
  initfn}
- deps: exec.library (lists/semaphores/msgports/ioreq/memory),
  utility.library v0+ (FindTagItem -30, NextTagItem -48),
  intuition.library v37 (OpenLibrary -552; internals patched at
  +0x704 for v39 / +0x76e for v37), input.device (OpenDevice -444,
  private DoIO commands 10/9), driver port names 'TabletPatch'
  (created) and 'APCommand' (talked to)
- initfn copies h1 bytes 0..0xc3 into lib+0x2e (strings become the
  lib's private name pool) and applies one self-fixup
  (h1+0xc4 count=1, h1+0xc8 offset 0x8e -> 'TabletPatch' string);
  sub-init h0+0x1a0 allocates a 0x1e00 pool (120 x 64B nodes on a
  NewList'd list), Inits two semaphores, then runs the
  install/uninstall worker h0+0x964 with arg=1

## Build

`tablet_h0.s` verbatim .text + .data (0xcc); `fixup.py` verifies
every hunk body then copies header/RELOC32 tails verbatim.
Byte-identical (md5 0088c764e143015401fb9cfed6f08c41).

## Runtime

`work/oracle.py`: init, all 8 vectors (incl. reserved -24),
open x2, alloc/getdata/cmd/free cycle, close x2 (deferred
expunge), real expunge (uninstall path).  Run with utility
v39 (fast 24B CopyMem path) and v36 (semaphored tag-walk path);
identical original vs rebuild in both.
