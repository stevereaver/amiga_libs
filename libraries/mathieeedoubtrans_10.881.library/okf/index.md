---
type: Library
title: mathieeedoubtrans_10.881.library
description: Kickstart 1.x IEEE double math library (68881/68882 FPU), reconstructed in C+asm.
tags: [math, ieee, 68881, kickstart-1.x]
---

# mathieeedoubtrans_10.881.library — Knowledge Bundle

## Overview

 mathieeedoubtrans.library "MDT 10.881" is the Kickstart 1.x disk-based IEEE double math
library for machines with a Motorola 68881/68882 floating-point coprocessor.
RomTag version 45 (0x2d), NT_LIBRARY, RTF_AUTOINIT; single code hunk.

- Original SHA256: `14957a826dd80d83ffe7f3dc7583882058d2c00939fa3c1ad310cc17653ddb1d`
- Original size: 788 bytes, single `.text` hunk of 0x2d4 bytes
- UAE twin: `../mathieeedoubtrans_10.881_UAE_.library` is **byte-for-byte identical** to this binary (same SHA256)
- No-FPU path: on missing AFF_68881: OpenLibrary("Libs:NoFPU/mathieeedoubtrans.library",36), CloseLibrary(result), then runs the shared NegSize/PosSize free tail on the base OpenLibrary returned and fails the resident init
- FPCR written by Open: 0x10 (unconditional)
- Reconstruction: `source/` builds a valid HUNK `.library` via the two-pass
  word-offset AUTOINIT table (`genfunctab.py`). Semantics verified against
  the disassembly; layout/size differ from the shipped binary (see findings).

## Categories

- [functions/](functions/index.md) — all LVO entries (-6 .. -62)
- [structures/](structures/index.md) — library base, AUTOINIT tables, jump vectors
- [algorithms/](algorithms/index.md) — FPU evaluation schemes (Pow, Floor/Ceil)
- [findings/](findings/index.md) — quirks, open questions, reconstruction deltas
- [log.md](log.md) — chronological work journal
