---
type: Library
title: crm_4.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:22:04.656382Z
---

# crm_4.1.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[1e]='CrM.library' idstr[2a]='CrM.library 4.1 - Crunch-Mania Interface for library decrunching Executables and Data Files V4.11 (04.10.93) (c) Thomas Schwarz\r\n' init=d2 endskip=21c4
  inittab: datasize=3a functab@e2 datatab@11e initfunc=13e
  functab: 14 vectors (abs-long)
    LVO -6   -> 0222
    LVO -12  -> 0230
    LVO -18  -> 023e
    LVO -24  -> 023e
    LVO -30  -> 0332
    LVO -36  -> 02d0
    LVO -42  -> 077e
    LVO -48  -> 07ca
    LVO -54  -> 09bc
    LVO -60  -> 0c38
    LVO -66  -> 0dc0
    LVO -72  -> 0fa8
    LVO -78  -> 0d9a
    LVO -84  -> 0dac

```

## Status

FULL - `source/` rebuilds byte-identical to `binary/` (verified by
fixup.py + cmp).  Per-vector C reference model: see source/ (or the
canonical API docs in okf/functions/).

## Contents

- [functions/](functions/index.md)
- [structures/](structures/index.md)
- [findings/](findings/index.md)
- [algorithms/](algorithms/index.md)
- [log.md](log.md)
