---
type: Library
title: mathieeesingtrans_10.881.library
description: Kickstart 1.x IEEE single math library (68881/68882 FPU), reconstructed in C+asm.
tags: [math, ieee, 68881, kickstart-1.x]
---

# mathieeesingtrans_10.881.library — Knowledge Bundle

## Overview

 mathieeesingtrans.library "MST 10.881" is the Kickstart 1.x disk-based IEEE single math
library for machines with a Motorola 68881/68882 floating-point coprocessor.
RomTag version 45 (0x2d), NT_LIBRARY, RTF_AUTOINIT; single code hunk.

- Original SHA256: `960d90a9d0b4346b027f00f7c0dae9a3c3234cfe88fccdd743af99e6fc0aef3b`
- Original size: 644 bytes, single `.text` hunk of 0x244 bytes
- UAE twin: `../mathieeesingtrans_10.881_UAE_.library` is **byte-for-byte identical** to this binary (same SHA256)
- No-FPU path: on missing AFF_68881: OpenLibrary("Libs:NoFPU/mathieeesingtrans.library",36), CloseLibrary(result), then runs the shared NegSize/PosSize free tail on the base OpenLibrary returned and fails the resident init
- FPCR written by Open: 0x80 (conditional)
- Reconstruction: `source/` builds a valid HUNK `.library` via the two-pass
  word-offset AUTOINIT table (`genfunctab.py`). Semantics verified against
  the disassembly; layout/size differ from the shipped binary (see findings).

## Categories

- [functions/](functions/index.md) — all LVO entries (-6 .. -62)
- [structures/](structures/index.md) — library base, AUTOINIT tables, jump vectors
- [algorithms/](algorithms/index.md) — FPU evaluation schemes (Pow, Floor/Ceil)
- [findings/](findings/index.md) — quirks, open questions, reconstruction deltas
- [log.md](log.md) — chronological work journal
