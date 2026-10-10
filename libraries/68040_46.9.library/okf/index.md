---
type: Library
title: 68040.library 46.9 (Lynxx)
description: >-
  "040/060-Loader" stub masquerading as 68040.library. 568 bytes,
  one code hunk. Forwards opens to "060.library" on 68060, tries to
  preload Libs:68040mmu.library on real 68040, then unloads itself.
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
   - **probe != 0 (68060):** `lb_OpenLib = OpenLibrary("060.library",0)`
     — the pointer is `str+2` into `"68060.library"` (sic). Fail→NULL,
     else return base; LibOpen then hands out the 060 library's base.
   - **probe == 0 (real 68040):** `LoadSeg("bs:68040mmu.library")` +
     InitResident — again a `str+2` pointer into `"Libs:..."` so it
     always fails; result discarded, init returns NULL either way
     (preload-then-die intent, defeated by the pointer quirk).

## Status

FULL — reconstructed in C + asm helpers; `make` in `source/` builds a
single-hunk `68040.library`.

## Categories

- [functions/](functions/index.md) — the four system vectors
- [structures/](structures/index.md) — RomTag/InitTable/hunk map, LibBase
- [findings/](findings/index.md) — +2 pointer quirks, LVO -810, etc.
- [log.md](log.md) — work journal
