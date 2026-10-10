---
type: Library
title: 68040.library 44.1 (Phase5 dummy)
description: >-
  Phase5 "dummy" 68040.library loader stub. 692 bytes, one code
  hunk. Preloads 68040new/68040old on real 68040s, forwards to
  "060.library" on FPU-less 040s, passes through on 68060.
tags: [68040, 68060, loader, phase5]
---

# 68040.library 44.1 (Phase5 dummy) — Knowledge Bundle

## Overview

A 692-byte loader stub by Ralph Schmidt / Phase5 (21.6.98) — the
companion "dummy" shipped next to their real CPU libraries.
Implements only the four system vectors; no user LVOs.

- `idstr: 68040.library 44.1 (21.6.98) © 1994-1998 by Phase5, written by Ralph Schmidt`
- `$VER:` duplicate without CRLF terminator
- sha256 `156f11f5c64ee8014f8b93f1128b7f0c6aa7c76f0e2f03b924f340fe46be5f47`
- one code hunk, 0x268 bytes; RomTag RT_VERSION=44, RTF_AUTOINIT
- InitTable: dataSize 0x38 (struct Library + 22 private bytes)

## Init behaviour

1. `pb_DOSBase = OpenLibrary("dos.library",0)`, fail if NULL
2. `AttnFlags & AFF_68060` → return base (stub stays resident)
3. `!(AttnFlags & AFF_68040)` → fail
4. `AttnFlags & AFF_FPU40` (full 040):
   LoadSeg+InitResident of `LIBS:68040new.library`, else
   `LIBS:68040old.library`; result kept in pb_LoadLib; init returns
   NULL **either way** — preload-then-die.
5. no FPU40 (LC/EC040): `pb_OpenLib = OpenLibrary("060.library",0)`
   — pointer lands 7 bytes into `"LIBS:68060.library"` (quirk);
   fail if NULL else return base.

LibOpen returns pb_OpenLib if set (redirection), else self.

## Status

FULL — reconstructed in C + asm helpers; `make` in `source/` builds
a single-hunk `68040.library`.

## Categories

- [functions/](functions/index.md) — the four system vectors
- [structures/](structures/index.md) — RomTag/InitTable/hunk map, LibBase
- [findings/](findings/index.md) — "060.library" quirk, ABI quirks
- [log.md](log.md) — work journal
