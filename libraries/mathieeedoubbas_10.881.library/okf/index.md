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
- Original size: 624 bytes, single `.text` hunk of 0x230 bytes
- UAE twin: `../mathieeedoubbas_10.881_UAE_.library` is **byte-for-byte identical** to this binary (same SHA256)
- No-FPU path: on missing AFF_68881, init OpenLibrarys (and immediately
  CloseLibrarys) the *path* `Libs:NoFPU/mathieeedoubbas.library` — which
  always fails — then FreeMem()s the freshly allocated library base
  without unlinking it and returns 0 (init fails)
- FPCR written by Open: 0x10 (unconditional)
- Reconstruction: `source/` builds a valid HUNK `.library` via the two-pass
  word-offset AUTOINIT table (`genfunctab.py`). Semantics verified against
  the disassembly; layout/size differ from the shipped binary (see findings).

## Categories

- [functions/](functions/index.md) — all LVO entries (-6 .. -52)
- [structures/](structures/index.md) — library base, AUTOINIT tables, jump vectors
- [algorithms/](algorithms/index.md) — FPU evaluation schemes (Pow, Floor/Ceil)
- [findings/](findings/index.md) — quirks, open questions, reconstruction deltas
- [log.md](log.md) — chronological work journal

## Rebuild status

`make` in `source/` is byte-identical (md5 `d045e9dab808f9331ad97bfc85e795dd`);
`work/oracle.py` runtime-verified identical across all 16 vectors and
both expunge paths. C model retained under `make cmodel`.
