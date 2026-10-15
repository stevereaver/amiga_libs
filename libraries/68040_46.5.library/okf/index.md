---
type: Library
title: 68040.library 46.5 (Phase5)
description: >-
  Phase5 68040.library loader stub. 748 bytes, one code hunk.
  Detects 68060 via a movec-pcr probe and forwards opens to
  68060.library; on a real 68040 preloads 68040new/68040old and dies.
tags: [68040, 68060, loader, phase5]
---

# 68040.library 46.5 (Phase5) — Knowledge Bundle

## Overview

A 748-byte loader stub by Ralph Schmidt / Phase5 (19.10.99) —
successor of the 44.1 "dummy". Implements only the four system
vectors; no user LVOs.

- `idstr: 68040.library 46.5 (19.10.99) © 1994-1999 by Phase5, written by Ralph Schmidt`
- `$VER:` duplicate without CRLF terminator
- sha256 `23882a06695ab3dc18a3a262307b12c57428ffd2a685d9307535612e2a21f118`
- one code hunk, 0x2a0 bytes; RomTag RT_VERSION=46, RTF_AUTOINIT
- InitTable: dataSize 0x38 (struct Library + 22 private bytes)

## Init behaviour

1. `pb_DOSBase = OpenLibrary("dos.library",0)`, fail if NULL
2. `!(AttnFlags & AFF_68040)` → fail
3. `Supervisor(movec pcr probe)` — PCR (CR 0x808) exists only on
   68060, so probe returns 1 on 060, 0 on a real 040:
   - **060:** `pb_OpenLib = OpenLibrary("68060.library",0)`; fail if
     NULL else return base → LibOpen hands out the 060 lib's base.
   - **real 040:** LoadSeg+InitResident `LIBS:68040new.library`, else
     `LIBS:68040old.library`; result in pb_LoadLib; init returns NULL
     either way (preload-then-die).

## Status

DONE — verbatim asm `source/68040_v.s` + `source/fixup.py`;
`make` produces a **byte-identical** 748B library (md5
`8333b7778869e23f481d32c03cf48f30`).  machine68k oracle
(`work/oracle.py`) is trace-identical over 7 scenarios: the real
`movec`/`rte` fault path runs under the harness (illegal-instruction
→ vector-4 handler → skip), plus forced-060 OpenLibrary path,
LoadSeg/InitResident new+old fallback, no-RomTag UnLoadSeg, and the
proxied LibOpen.  Older C model kept under `make cmodel`.

## Categories

- [functions/](functions/index.md) — the four system vectors
- [structures/](structures/index.md) — RomTag/InitTable/hunk map, LibBase
- [findings/](findings/index.md) — PCR probe, ABI quirks
- [log.md](log.md) — work journal
