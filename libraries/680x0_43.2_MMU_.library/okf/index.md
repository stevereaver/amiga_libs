---
type: Library
title: 680x0.library 40.4
description: >-
  THOR MMULib CPU-driver dispatcher library
  ($VER: 680x0.library 40.4 (25.11.2001) (c) 1999,2001 The MMU.lib development
  group, THOR; 864 bytes, 2 hunks).
timestamp: 2026-10-10T18:00:00Z
---

# 680x0.library 40.4

680x0.library from Thomas Richter's MMULib distribution.  It is a
tiny dispatcher (864 bytes): at init it detects the CPU from
`ExecBase->AttnFlags` (plus a supervisor `movec pcr` probe), opens
the matching CPU-specific driver `680N0.library` (version >=
40) and expunges itself when the driver is missing.

## Binary facts

- sha256 `0ee5b0affea37da56a32d493bd0f16914d26b6f77844a48c8e25c1b9a167b92b`, 864 bytes
- hunks: .text 524 / .data 168, 2 hunks, HAS_RELOC
- RomTag: RTF_AUTOINIT, version 40, NT_LIBRARY, pri 0; rt_EndSkip stored as literal 0
- 8 vectors: 4 standard + CPUType(-30), FPUType(-36), MMUType(-42), SetFPUExceptions(-48)
- function table: absolute longword pointers, -1L terminated

The shipped file is named "680x0_43.2(MMU).library" but its bytes are **identical** (same sha256) to `680x0_40.4.library`; it really is the 40.4 build.

## Status

BYTE-IDENTICAL + RUNTIME-IDENTICAL — the shipped file is a
byte-identical duplicate of `680x0_40.4.library` (same md5
15b5c19179d162c850fa5dfe7dcfa93d); the verbatim asm
`source/680x0_h0.s` from the 40.4 rebuild compiles to the same
bytes.  `make cmodel` retains the C reconstruction.
`work/oracle.py` (same harness as 40.4) verifies identical
orig/rebuild behaviour over the full scenario matrix.

## Contents

- [functions/](functions/index.md) — one concept per LVO (-6 .. -48)
- [structures/](structures/index.md) — library base, InitTable, hunk map
- [findings/](findings/index.md) — quirks and version differences
- [log.md](log.md) — work journal
