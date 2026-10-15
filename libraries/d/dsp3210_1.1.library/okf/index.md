---
type: Library
title: dsp3210.library 1.1
description: >-
  Thomas Winischhofer's AT&T DSP3210 support library (2020 rebuild),
  1180 bytes, single code hunk. NON-AUTOINIT resident module that
  bootstraps itself with MakeLibrary+AddLibrary. Exports two user
  functions: DSPCalcLen and DSPRelocate, a loader/relocator for d32
  object "blobs".
tags: [dsp3210, d32, loader, relocator, non-autoinit]
timestamp: 2026-10-10T20:10:00Z
---

# dsp3210.library 1.1 — Knowledge Bundle

`binary/dsp3210_1.1.library` — sha256
`a218902bbe4e7690048b6fb1f7f1a389a92054fb413247eafbd79b75579420d9`,
1180 bytes, one code hunk (0x43c bytes). IdString:
`dsp3210.library 1.1 (3.1.2020)` (`$VER:` cookie present, IdString
points past it).

## Status

BYTE-IDENTICAL - verbatim asm `source/dsp3210_h0.s` + `fixup.py`
(11-entry descending-order RELOC32 splice): `cmp`-equal to the
shipped binary (md5 `80b56d6f33b764b86ba8a80383d4cb27`).
machine68k oracle identical over rt_Init MakeLibrary+AddLibrary
bootstrap, libInit, all 6 vectors, expunge (Remove+FreeMem) and
DSPCalcLen/DSPRelocate on a synthetic valid/invalid d32 blob.
Semantic C model kept as `cmodel` target.  LVO names from the
official `dsp3210_lib.fd` (Aminet `driver/other/dsp3210`).

## Contents

- [functions/](functions/index.md) — all 6 LVO entries (-6 .. -36)
- [structures/](structures/index.md) — DSP3210Base, d32 blob format, InitTable/hunk map
- [algorithms/](algorithms/index.md) — the d32 relocation algorithm
- [findings/](findings/index.md) — quirks, API drift, open questions
- [log.md](log.md) — work journal

## External references

- Aminet `driver/other/dsp3210.lha` (v7.x): `fd/dsp3210_lib.fd` —
  the current 11-function API (this 1.1 build exports only the first
  two); `include/libraries/dsp3210.h` — current error codes (odd
  negatives; this build uses the old even numbering).
