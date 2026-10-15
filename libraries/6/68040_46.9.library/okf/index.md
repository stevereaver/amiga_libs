---
type: Library
title: 68040.library 46.9 (Lynxx)
description: >-
  "040/060-Loader" stub masquerading as 68040.library. 568 bytes,
  one code hunk. Forwards opens to 68060.library on 68060, preloads
  Libs:68040mmu.library via LoadSeg+InitResident on real 68040, then
  unloads itself.
tags: [68040, 68060, loader, lynxx]
---

# 68040.library 46.9 (Lynxx) — Knowledge Bundle

## Overview

A 568-byte loader stub by Holger 'Lynxx' Hippenstiel (21.11.2020).
Implements only the four system vectors — no user LVOs.

- `$VER: 040/060-Loader.library 46.9 (21.11.2020) by Holger 'Lynxx' Hippenstiel.`
- sha256 `f55838ca8367a4a46d7dd964a11b9d0f4db0f4481e0dc2ff52bb1564a4f538c1`
- one code hunk, 0x1cc bytes; RomTag RT_VERSION=46, RTF_AUTOINIT
- InitTable: dataSize 0x34 (struct Library + 18 private bytes)
- 4 vectors only: Open (-6) plus one shared null stub for
  Close/Expunge/ExtFunc (-12/-18/-24)

## Init behaviour

1. `lb_DOSBase = TaggedOpenLibrary(4)` — exec LVO -810, no NULL check
2. `if (!(AttnFlags & AFF_68040)) return NULL`
3. `Supervisor(movec pcr probe)`: PCR is 68060-only.
   - **probe != 0 (68060):** `lb_OpenLib = OpenLibrary("68060.library",0)`.
     Fail→NULL, else return base; LibOpen then hands out the 060
     library's base.
   - **probe == 0 (real 68040):** `LoadSeg("Libs:68040mmu.library")` +
     RomTag scan + InitResident; result discarded — init returns NULL
     either way (preload-then-die by design).

## Status

DONE — byte-identical pure-asm rebuild (`source/68040.s`,
`make` → md5 `32ad08d5d71301b0bf9b494bc39cdffe`).
Runtime-verified under machine68k: oracle exercises both init
branches (probe fault → LoadSeg/InitResident; forced probe=1 →
OpenLibrary + proxy open), the RomTag walk, and all four vectors —
identical traces original vs rebuild. The earlier C model is kept as
`make cmodel` (documentation, not byte-identical).

## Categories

- [functions/](functions/index.md) — the four system vectors
- [structures/](structures/index.md) — RomTag/InitTable/hunk map, LibBase
- [findings/](findings/index.md) — PCR probe, fault-skip, ABI quirks
- [log.md](log.md) — work journal
