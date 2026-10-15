---
type: Library
title: mathieeedoubtrans_10.881.library
description: Kickstart 1.x IEEE double math library (68881/68882 FPU), byte-identical asm reconstruction.
tags: [math, ieee, 68881, kickstart-1.x]
---

# mathieeedoubtrans_10.881.library — Knowledge Bundle

## Overview

UAE-badged twin of `mathieeedoubtrans_10.881.library`; identical bytes. mathieeedoubtrans.library "MDT 10.881" is the Kickstart 1.x disk-based IEEE double math
library for machines with a Motorola 68881/68882 floating-point coprocessor.
RomTag version 45 (0x2d), NT_LIBRARY, RTF_AUTOINIT; single code hunk.

- Original MD5: `abb7adf47d2f40b3d8c0bbf852c2875a`
- Original SHA256: `14957a826dd80d83ffe7f3dc7583882058d2c00939fa3c1ad310cc17653ddb1d`
- Original size: 788 bytes, single `.text` hunk of 0x2d4 bytes
- UAE twin: `../mathieeedoubtrans_10.881.library` is **byte-for-byte identical** to this binary (same MD5/SHA256)
- Status: **DONE** — byte-identical rebuild verified (`cmp`, md5 match)
- No-FPU path: on missing AFF_68881 the init routine pushes the fresh
  base, opens + immediately closes `Libs:NoFPU/mathieeedoubtrans.library`
  v36, pops the base into a1 and frees it via the shared NegSize/PosSize
  tail; returns the still-zero segcell -> resident init fails
- FPCR written by Open: 0x10 (unconditional)
- Reconstruction: `make` builds `source/mathieeedoubtrans_h0.s` — a verbatim
  transcription — and `fixup.py` rewrites GNU ld's RELOC32 tail into the
  original compact 16-bit 0x3f7 chunk.  Result is **byte-identical**
  (md5 above).  The earlier C+asm model is kept as `make cmodel`.
- Oracle: `work/oracle.py` emulates the 68881 subset via the line-F
  vector; logs for original and rebuild are **identical**
  (runtime-identical).  The UAE twin produces the same log.

## Categories

- [functions/](functions/index.md) — all LVO entries (-6 .. -126)
- [structures/](structures/index.md) — library base, AUTOINIT tables, jump vectors
- [algorithms/](algorithms/index.md) — 68881 evaluation schemes
- [findings/](findings/index.md) — quirks, hunk tail, reconstruction notes
- [log.md](log.md) — chronological work journal
