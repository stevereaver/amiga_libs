---
type: Library
title: idn.library 0.1 (13-Mar-2004)
description: >-
  IDNA/punycode helper library: nameprep-style string fold,
  punycode encode/decode, free.  Uses regexp.library for label
  validation.  Rebuild is byte-identical via h0.s + fixup.py.
timestamp: 2026-10-15T08:40:00Z
---

# idn.library 0.1

IDNA (Internationalized Domain Names) support library.  Four user
vectors; function names are reconstructed (no fd ships).

## Binary facts

- 6220 bytes; single CODE hunk 0x165c
- RomTag: AUTOINIT, v0 r1
- idstring `idn.library 0.1 13-Mrz-2004`
- opens `regexp.library` internally for label validation
- character class string `[0-9a-zA-Z-]` embedded

## API (reconstructed names)

| LVO | Name | Semantics |
|-----|------|-----------|
| -30 | IDN_Normalize | tolower A-Z, 0xdf->"ss", strip 0xad |
| -36 | IDN_Encode | name check + punycode encode -> AllocMem |
| -42 | IDN_Decode | punycode decode -> AllocMem |
| -48 | IDN_Free | FreeMem(strlen+1) |

## Status

FULL - byte-identical rebuild (source/h0.s + fixup.py); C model
idn.c ports -30/-48 exactly and the punycode constants/adapt loop
of -36/-42 structurally.

## Contents

- [functions/](functions/index.md) - [structures/](structures/index.md)
- [findings/](findings/index.md) - [algorithms/](algorithms/index.md) - [log.md](log.md)
