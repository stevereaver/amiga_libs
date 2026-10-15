---
type: Library
title: ak_gen0_38.22.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:25.162584Z
---

# ak_gen0_38.22.library

## Structure scan

```
romtag@4 flags=80 ver=38 type=9 pri=22
  name[1e]='ak_gen0.library' idstr[2e]='ak_gen0 38.22 (6.5.1994)\r\n' init=9c endskip=9c
  inittab: datasize=3e functab@ac datatab@13c initfunc=15c
  functab: 4 vectors (abs-long)
    LVO -6   -> 01f2
    LVO -12  -> 0200
    LVO -18  -> 0214
    LVO -24  -> 02a4

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
