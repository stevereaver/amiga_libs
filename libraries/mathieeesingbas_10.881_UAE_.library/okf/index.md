---
type: Library
title: mathieeesingbas_10.881.library
description: Kickstart 1.x IEEE single math library (68881/68882 FPU), reconstructed in C+asm.
tags: [math, ieee, 68881, kickstart-1.x]
---

# mathieeesingbas_10.881.library — Knowledge Bundle

## Overview

UAE-badged twin of `mathieeesingbas_10.881.library`; identical bytes. mathieeesingbas.library "MSB 10.881" is the Kickstart 1.x disk-based IEEE single math
library for machines with a Motorola 68881/68882 floating-point coprocessor.
RomTag version 45 (0x2d), NT_LIBRARY, RTF_AUTOINIT; single code hunk.

- Original SHA256: `2efea2bb5f27557e846bb0101b00a013f4b66370002f8bfd449247ff5e287c10`
- Original size: 520 bytes, single `.text` hunk of 0x1c8 bytes
- UAE twin: `../mathieeesingbas_10.881.library` is **byte-for-byte identical** to this binary (same SHA256)
- No-FPU path: none -- on missing AFF_68881 the init routine frees the freshly allocated base and fails the resident init (returns 0)
- FPCR written by Open: 0x80 (conditional)
- Reconstruction: `source/` builds a valid HUNK `.library` via the two-pass
  word-offset AUTOINIT table (`genfunctab.py`). Semantics verified against
  the disassembly; layout/size differ from the shipped binary (see findings).

## Categories

- [functions/](functions/index.md) — all LVO entries (-6 .. -52)
- [structures/](structures/index.md) — library base, AUTOINIT tables, jump vectors
- [algorithms/](algorithms/index.md) — FPU evaluation schemes (Pow, Floor/Ceil)
- [findings/](findings/index.md) — quirks, open questions, reconstruction deltas
- [log.md](log.md) — chronological work journal
