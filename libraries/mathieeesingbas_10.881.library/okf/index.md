---
type: Library
title: mathieeesingbas_10.881.library
description: Kickstart 1.x IEEE single math library (68881/68882 FPU), byte-identical asm reconstruction.
tags: [math, ieee, 68881, kickstart-1.x]
---

# mathieeesingbas_10.881.library — Knowledge Bundle

## Overview

 mathieeesingbas.library "MSB 10.881" is the Kickstart 1.x disk-based IEEE single math
library for machines with a Motorola 68881/68882 floating-point coprocessor.
RomTag version 45 (0x2d), NT_LIBRARY, RTF_AUTOINIT; single code hunk.

- Original SHA256: `2efea2bb5f27557e846bb0101b00a013f4b66370002f8bfd449247ff5e287c10`
- Original MD5: `3e7f4b125c23ac45849af05ebcd587ce`
- Original size: 520 bytes, single `.text` hunk of 0x1c8 bytes
- UAE twin: `../mathieeesingbas_10.881_UAE_.library` is **byte-for-byte identical** to this binary (same SHA256)
- No-FPU path: on missing AFF_68881 the init routine frees the freshly allocated base and fails the resident init (returns 0)
- FPCR written by Open: 0x80 (conditional: when FPCR is 0 or in [0x40,0x80))
- Reconstruction: `make` builds `source/mathieeesingbas.s` — a verbatim
  transcription — and `fixup.py` rewrites GNU ld's RELOC32 tail into the
  original compact 16-bit 0x3f7 chunk.  Result is **byte-identical**
  (md5 above).  The earlier C+asm model is kept as `make cmodel`.
- Oracle: `work/oracle.py` emulates the 68881 subset via the line-F
  vector; logs for original and rebuild are identical.

## Categories

- [functions/](functions/index.md) — all LVO entries (-6 .. -96)
- [structures/](structures/index.md) — library base, AUTOINIT tables, jump vectors
- [algorithms/](algorithms/index.md) — 68881 evaluation schemes
- [findings/](findings/index.md) — quirks, hunk tail, reconstruction notes
- [log.md](log.md) — chronological work journal
