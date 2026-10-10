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

Fully reconstructed in C. `source/` builds a single-hunk `.library`
with the same non-AUTOINIT RomTag, same six-vector absolute-long
function table, and semantically identical loader logic. All 6 LVO
slots resolved; the two user functions are named from the official
`dsp3210_lib.fd` in the Aminet `driver/other/dsp3210` package
(Thomas Winischhofer, maintained at github.com/realA10001986/AmigaDSP3210).

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
