---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2026-10-10
- Phase 1: dumped binary with `ira -M68020` into `work/`; decoded
  RomTag (RTF_AUTOINIT, version 47, NT_LIBRARY, EndSkip=0),
  InitTable (dataSize 0x40) and the absolute-longword function table
  (8 vectors).  API identified from Mu680x0Libs 47.2 distribution
  headers (`Include/lvo/680x0_lvo.i`, `libraries/680x0.h`,
  `Autodocs/680x0.doc`): CPUType -30, FPUType -36, MMUType -42,
  SetFPUExceptions -48 (forwards to driver LVO -222 = FPUControl).
- Phase 2: C reconstruction (`source/`): all logic in 680x0.c,
  RomTag/InitTable/functab/strings in 680x0_lib.s, supervisor-mode
  CPU probe in cpuprobe.s (asm required: movec/VBR/RTE).  Absolute
  long functab -> single link pass (version_37.67 pattern).
  `make` OK; data hunk byte-identical modulo vector relocs; code
  verified against disassembly.
- Phase 3: okf bundle populated.

- Phase 4 (2026-10-15): verbatim asm `680x0_h0.s` -> BYTE-IDENTICAL
  (md5 6c98b316d624d1e087c019c8100df4a5).  47.2 deltas vs the 40.4
  build: PCR signature check (0x043x -> '6', other -> 'A' Apollo),
  driver OpenLibrary arg 46, 'A' makes _open680x0 return 0 (init
  self-frees on Apollo), dead unreferenced "apollo.library" string
  at data+0x42, Close still never expunges, rt_EndSkip=0,
  idstr points past the $VER: cookie.  machine68k oracle identical.
