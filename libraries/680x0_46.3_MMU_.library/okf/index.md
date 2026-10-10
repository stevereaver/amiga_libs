---
type: Library
title: 680x0.library 46.1
description: >-
  THOR MMULib CPU-driver dispatcher library
  ($VER: 680x0.library 46.1 (04.07.2016) (c) 1999-2016 The MMU.lib development
  group, THOR; 864 bytes, 2 hunks).
timestamp: 2026-10-10T18:00:00Z
---

# 680x0.library 46.1

680x0.library from Thomas Richter's MMULib distribution.  It is a
tiny dispatcher (864 bytes): at init it detects the CPU from
`ExecBase->AttnFlags` (plus a supervisor `movec pcr` probe), opens
the matching CPU-specific driver `680N0.library` (version >=
46) and expunges itself when the driver is missing.

## Binary facts

- sha256 `cf87c9b2a055b7c6eebaf89a062eee7c7a4ada5ea242d8025132c51a36b43861`, 864 bytes
- hunks: .text 524 / .data 168, 2 hunks, HAS_RELOC
- RomTag: RTF_AUTOINIT, version 46, NT_LIBRARY, pri 0; rt_EndSkip stored as literal 0
- 8 vectors: 4 standard + CPUType(-30), FPUType(-36), MMUType(-42), SetFPUExceptions(-48)
- function table: absolute longword pointers, -1L terminated

The shipped file is named "680x0_46.3(MMU).library" but its bytes are **identical** to `680x0_46.1(MMU).library`; it really is the 46.1 build.

## Status

Reconstructed (`source/`, m68k-amigaos-gcc): C for all logic plus a
small hand-written `cpuprobe.s` for the supervisor-state CPU/PCR
probe (VBR redirect + illegal-instruction trampoline - not
expressible in C).  `make` produces a loadable `.library`; the data
hunk (InitTable, function table layout, strings) is byte-identical
to the original modulo the relocated vector pointers, and the code
was verified function-by-function against the IRA disassembly.

## Contents

- [functions/](functions/index.md) — one concept per LVO (-6 .. -48)
- [structures/](structures/index.md) — library base, InitTable, hunk map
- [findings/](findings/index.md) — quirks and version differences
- [log.md](log.md) — work journal
