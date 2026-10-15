---
type: Library
title: ak_gen1_38.85.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:33.792706Z
---

# ak_gen1_38.85.library

## Structure scan

```
romtag@4 flags=80 ver=35 type=9 pri=85
  name[1e]='ak_gen1.library' idstr[2e]='ak_gen1 35.85 (29 Mar 1993)\r\n' init=7c endskip=7c
  inittab: datasize=14a functab@8c datatab@138 initfunc=158
  functab: 4 vectors (abs-long)
    LVO -6   -> 0206
    LVO -12  -> 0214
    LVO -18  -> 0228
    LVO -24  -> 02be

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
