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

BYTE-IDENTICAL + RUNTIME-IDENTICAL — the file shipped as
`680x0_46.3(MMU).library` is a byte-for-byte duplicate of the 46.1
build (md5 `edbf249db38de0b48641bbf9fb62ddf3`); its embedded
idstring still reads `46.1 (04.07.2016)`, so it is a mislabeled
duplicate shipment, not a distinct 46.3 build.  Rebuilt via the
shared verbatim `source/680x0_h0.s`; `make cmodel` retains the C
reconstruction.  machine68k oracle identical over the full scenario
matrix.

## Contents

- [functions/](functions/index.md) — one concept per LVO (-6 .. -48)
- [structures/](structures/index.md) — library base, InitTable, hunk map
- [findings/](findings/index.md) — quirks and version differences
- [log.md](log.md) — work journal
