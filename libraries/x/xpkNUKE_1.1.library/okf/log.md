---
type: Log
title: Work Log
description: Chronological journal of analysis sessions.
---

# Log

## 2026-10-15
- Parsed hunk: HUNK_HEADER 2 hunks — CODE 0x2bd longs @file 0x24,
  DATA 0x50 longs @file 0xb84.  RELOC32 h0: 16->h0 (descending
  functab block + RomTag/init refs), 2->h1; h1: 2->h0 (InitTable).
- AUTOINIT RomTag @+0x04, EndSkip 0x1e; rt_Init -> data+4 ->
  InitTable {0x156, funcTab=code+0xaa4 (absolute longs + ffffffff),
  dataTab=0, initFn=code+0x20}.  initFn memcpy's data hunk ->
  lib+0x3a and self-relocates 8 internal pointers (tbl data+0x120).
- Generated source/xpkNUKE_h0.s via work/gen_source.py
  (transcribe-style): .byte spans for RomTag/pads, class tables
  (0x36c-0x433) and functab/strings (0xaa2-0xaf3); verified
  mnemonics elsewhere. 5 insns forced raw by the assemble-compare
  loop: 4x `lea a6@(0),a4` (gas picks the 49ee->4aee short form)
  and one jsr pc@(Laf0).
- source/xpkNUKE_h1.s: 320B verbatim data hunk.  Two-object link
  (-m68020, -nostdlib -nostartfiles -Wl,-s) emits CODE+DATA in
  order; fixup.py splices original RELOC32 tails after verifying
  bodies -> BYTE-IDENTICAL, md5 bb4257fa0250c2259f600754808843da.
- work/oracle.py (machine68k, M68020): loads both hunks, applies
  relocs, emulates MakeLibrary/AUTOINIT, stubs AllocMem/FreeMem/
  Remove (AllocMem failure injection for the -7 path).  Exercises
  resident init, open/close/deferred+real expunge, all 10 vectors,
  PackerInfo fields, 20-corpus pack -> stored streams, unpack
  round-trips, workspace reuse (no-realloc path), PackFree stale
  pointer, -17 expansion paths, alloc-fail -7, garbage unpack.
- Original vs rebuild: log diff clean, all streams byte-identical.
  Observed quirk: 40000B input > MaxPkInChunk 30000 packs rc=0 but
  fails to round-trip on the ORIGINAL too — faithfully reproduced.
