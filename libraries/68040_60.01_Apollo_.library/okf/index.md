---
type: Library
title: 68040.library 60.01 (Apollo)
description: >-
  Apollo loader stub masquerading as 68040.library. 392 bytes, one
  code hunk. Pre-loads "68o4o.library" or "68060.library" at init.
tags: [68040, 68060, apollo, loader]
---

# 68040.library 60.01 (Apollo) — Knowledge Bundle

## Overview

Despite the name this is NOT the real CPU-support library: it is a
392-byte loader stub by Z. Urwani (Apollo team), dated 08 Dec 1995.
Its only purpose is that `OpenLibrary("68040.library")` succeeds and
that a real support library is pulled into exec's library list as a
side effect of resident initialization.

- `$VER:68o4o/68060.library-loader 60.01 (08 Dec 1995 Z.Urwani)`
- sha256 `c9dc685ad64694c758327936940dd69426f98bc82c8302b315b51bafb5b7f932`
- one code hunk, 0x11c bytes; RomTag RT_VERSION=60, RTF_AUTOINIT
- InitTable: dataSize 0x22 (a bare `struct Library`, no privates)
- 4 vectors only: Open (-6), Close (-12), Expunge (-18), ExtFunc (-24);
  no user LVOs at all

## Init behaviour

`LibInit` (d0=base, a0=seglist, a6=SysBase):

1. `if (!(AttnFlags & AFF_68040)) return NULL`
2. `if (AttnFlags == 0x80ff) return base` — the support lib's
   "already installed" marker: succeed without loading again
3. `AFF_FPU40` set → `OpenLibrary("68o4o.library", 0)` (letter 'o'!)
   else → `OpenLibrary("68060.library", 0)`
4. fail if that open failed, else return the base.

The opened library is never closed (deliberate leak → stays resident).

## Status

FULL — **byte-identical rebuild**: `make` in `source/` assembles
68040.s into md5 `a87e68a0e398d03466cc5443f524fbe7`, matching the
original exactly. The earlier C reconstruction is kept as
`make cmodel` (semantic reference, not byte-identical).
work/oracle.py (machine68k) produces identical traces for the
original and the rebuild across the init scenario matrix and all
four vectors.

## Categories

- [functions/](functions/index.md) — the four system vectors
- [structures/](structures/index.md) — RomTag/InitTable/hunk map
- [findings/](findings/index.md) — quirks and open questions
- [log.md](log.md) — work journal
