---
type: Library
title: mathieeedoubbas_10.881.library
description: Kickstart 1.x IEEE double math library (68881/68882 FPU), byte-identical asm reconstruction.
tags: [math, ieee, 68881, kickstart-1.x]
---

# mathieeedoubbas_10.881.library — Knowledge Bundle

## Overview

 mathieeedoubbas.library "MDB 10.881" is the Kickstart 1.x disk-based IEEE double math
library for machines with a Motorola 68881/68882 floating-point coprocessor.
RomTag version 45 (0x2d), NT_LIBRARY, RTF_AUTOINIT; single code hunk.

- Original SHA256: `398aa5cc85e5c7124d5f13861d83ede69f562136c77ba27f0381705775083df0`
- Original MD5: `d045e9dab808f9331ad97bfc85e795dd`
- Original size: 624 bytes, single `.text` hunk of 0x230 bytes
- Status: **DONE** — byte-identical rebuild + runtime-identical oracle
- UAE twin: `../mathieeedoubbas_10.881_UAE_.library` is **byte-for-byte identical** to this binary (same SHA256)
- No-FPU path: on missing AFF_68881 the init routine opens/closes
  "Libs:NoFPU/mathieeedoubbas.library" v36, frees its own fresh base via
  the shared NegSize/PosSize tail and fails the resident init (returns 0)
- FPCR written by Open: 0x10, unconditionally (extended precision +
  round-toward-zero -- makes IEEEDPFix truncate like a C cast)
- Reconstruction: `make` builds `source/mathieeedoubbas_h0.s` -- a verbatim
  transcription -- and `fixup.py` rewrites GNU ld's RELOC32 tail into the
  original compact 16-bit 0x3f7 chunk.  Result is **byte-identical**
  (md5 above).  The earlier C+asm model is kept as `make cmodel`.
- Oracle: `work/oracle.py` emulates the 68881 subset via the line-F
  vector (incl. `(a7)`/`(a7)+`/`-(a7)` double loads/stores through the
  USP register and FPCR rounding modes); logs for original and rebuild
  are identical (`diff orig.log rebuild.log` empty).

## Categories

- [functions/](functions/index.md) — all LVO entries (-6 .. -96)
- [structures/](structures/index.md) — library base, AUTOINIT tables, jump vectors
- [algorithms/](algorithms/index.md) — 68881 evaluation schemes
- [findings/](findings/index.md) — quirks, hunk tail, reconstruction notes
- [log.md](log.md) — chronological work journal
