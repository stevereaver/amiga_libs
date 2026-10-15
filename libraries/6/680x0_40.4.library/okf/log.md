---
type: Log
title: Work Log
description: Chronological journal of analysis sessions for this library. Newest first.
---

# Log

## 2026-10-10
- Phase 1: dumped binary with `ira -M68020` into `work/`; decoded
  RomTag (RTF_AUTOINIT, version 40, NT_LIBRARY, EndSkip=0),
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
  (md5 15b5c19179d162c850fa5dfe7dcfa93d).  machine68k oracle verifies CPU
  ladder (AttnFlags -> '1'/'2'/'4', forced-060 -> '6'), driver-open
  name patching on the stack, self-free on driver-missing and
  exec-v<36 paths, and CPUType/FPUType/MMUType/SetFPUExceptions
  incl. the driver -222 forwarding.  orig vs rebuild logs identical.
