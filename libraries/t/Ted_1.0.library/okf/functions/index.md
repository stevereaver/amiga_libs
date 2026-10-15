---
type: Index
title: Functions
description: Exported functions and LVO entries analyzed for this library.
timestamp: 2026-10-10T20:20:00Z
---

# Functions

- [LibOpen](LibOpen.md) — LVO -6
- [LibClose](LibClose.md) — LVO -12
- [LibExpunge](LibExpunge.md) — LVO -18
- [Reserved](Reserved.md) — LVO -24 stub
- [SetG1](SetG1.md) — LVO -30 `g1 = a0`
- [SetG2](SetG2.md) — LVO -36 `g2 = a0`
- [GetG1](GetG1.md) — LVO -42 `d0 = *g1` (long)
- [GetG2Word](GetG2Word.md) — LVO -48 `d0 = *g2` (uword)
- [SetG3](SetG3.md) — LVO -54 `g3 = a0`
- [GetG3](GetG3.md) — LVO -60 `d0 = g3`
- [CallG3Method12](CallG3Method12.md) — LVO -66 `jmp *(g3+12)`
- [SetG4](SetG4.md) — LVO -72 `g4 = a0`
- [SetG5](SetG5.md) — LVO -78 `g5 = a0`
- [GetG4](GetG4.md) — LVO -84 `d0 = *g4`
- [GetG5](GetG5.md) — LVO -90 `d0 = *g5`
- [CallG3Method100](CallG3Method100.md) — LVO -96 `buf = (*(g3+100))(buf)`
- [CopyG3Str104](CopyG3Str104.md) — LVO -102 `buf = strcpy(*(g3+104))`
- [CopyG3Str108](CopyG3Str108.md) — LVO -108 `buf = strcpy(*(g3+108))`
- [GetG3Ptr112Field](GetG3Ptr112Field.md) — LVO -114 `d0 = *(*(g3+112)-2)`
- [GetG3Ptr116Field](GetG3Ptr116Field.md) — LVO -120 `d0 = *(*(g3+116)-2)`
