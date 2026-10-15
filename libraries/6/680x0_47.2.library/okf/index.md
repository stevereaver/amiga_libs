---
type: Library
title: 680x0.library 47.2
description: >-
  THOR MMULib CPU-driver dispatcher library
  ($VER: 680x0.library 47.2 (19.3.2022) (c) 1999-2017 The MMU.lib development
  group, THOR; 916 bytes, 2 hunks).
timestamp: 2026-10-10T18:00:00Z
---

# 680x0.library 47.2

680x0.library from Thomas Richter's MMULib distribution.  It is a
tiny dispatcher (916 bytes): at init it detects the CPU from
`ExecBase->AttnFlags` (plus a supervisor `movec pcr` probe), opens
the matching CPU-specific driver `680N0.library` (version >=
46) and expunges itself when the driver is missing.

## Binary facts

- sha256 `6a559d4883832fd112beedaf2c6b4d9a845d2b1c63e053918928ed4dd7251a51`, 916 bytes
- hunks: .text 560 / .data 184, 2 hunks, HAS_RELOC
- RomTag: RTF_AUTOINIT, version 47, NT_LIBRARY, pri 0; rt_EndSkip stored as literal 0
- 8 vectors: 4 standard + CPUType(-30), FPUType(-36), MMUType(-42), SetFPUExceptions(-48)
- function table: absolute longword pointers, -1L terminated

Binary is byte-identical to the official Mu680x0Libs 47.2 release (Aminet `util/sys/Mu680x0Libs.lha`, `Libs/680x0.library`).

## Status

BYTE-IDENTICAL + RUNTIME-IDENTICAL — `source/680x0_h0.s` builds
md5 `6c98b316d624d1e087c019c8100df4a5`, matching the shipped binary
(916B, CODE 0x230 + DATA 0xb8).  `make cmodel` retains the C
reconstruction.  machine68k oracle identical over the full matrix
(cpu ladder 010/020/040, forced probe results incl. the NEW 'A'
Apollo path, driver-missing/exec-v33 self-free, mmu absent,
SetFPUExceptions forwarding).

## Contents

- [functions/](functions/index.md) — one concept per LVO (-6 .. -48)
- [structures/](structures/index.md) — library base, InitTable, hunk map
- [findings/](findings/index.md) — quirks and version differences
- [log.md](log.md) — work journal
