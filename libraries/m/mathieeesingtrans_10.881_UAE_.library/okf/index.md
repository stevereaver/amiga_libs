---
type: Library
title: mathieeesingtrans_10.881_UAE_.library
description: Kickstart 1.x IEEE single math library (68881/68882 FPU), byte-identical asm reconstruction.
tags: [math, ieee, 68881, kickstart-1.x]
---

# mathieeesingtrans_10.881_UAE_.library — Knowledge Bundle

## Overview

 mathieeesingtrans.library "MST 10.881" is the Kickstart 1.x disk-based IEEE single math
library for machines with a Motorola 68881/68882 floating-point coprocessor.
RomTag version 45 (0x2d), NT_LIBRARY, RTF_AUTOINIT; single code hunk.

- Original MD5: `72797e9959324e0eede21e4573c3d7d3`
- Original SHA256: `960d90a9d0b4346b027f00f7c0dae9a3c3234cfe88fccdd743af99e6fc0aef3b`
- Original size: 644 bytes, single `.text` hunk of 0x244 bytes
- UAE twin: this IS the `_UAE_` variant; `../mathieeesingtrans_10.881.library` is **byte-for-byte identical** to this binary (same MD5/SHA256)
- Status: **DONE** — byte-identical rebuild verified (`cmp`, md5 match)
- No-FPU path: on missing AFF_68881 the init routine pushes the fresh
  base, opens + immediately closes `Libs:NoFPU/mathieeesingtrans.library`
  v36, pops the base into a1 and frees it via the shared NegSize/PosSize
  tail; returns the still-zero segcell -> resident init fails
- FPCR written by Open: 0x80 (conditional: when FPCR is 0 or in [0x40,0x80))
- Reconstruction: `make` builds `source/mathieeesingtrans.s` — a verbatim
  transcription — and `fixup.py` rewrites GNU ld's RELOC32 tail into the
  original compact 16-bit 0x3f7 chunk.  Result is **byte-identical**
  (md5 above).  The earlier C+asm model is kept as `make cmodel`.
- Oracle: `work/oracle.py` emulates the 68881 subset via the line-F
  vector; logs for original and rebuild are **identical**
  (runtime-identical).  Both twins produce the same log.

## Categories

- [functions/](functions/index.md) — all LVO entries (-6 .. -126)
- [structures/](structures/index.md) — library base, AUTOINIT tables, jump vectors
- [algorithms/](algorithms/index.md) — 68881 evaluation schemes
- [findings/](findings/index.md) — quirks, hunk tail, reconstruction notes
- [log.md](log.md) — chronological work journal
