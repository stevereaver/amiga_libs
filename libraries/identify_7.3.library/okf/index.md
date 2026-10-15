---
type: Library
title: identify_7.3.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:24.820515Z
---

# identify_7.3.library

## Structure scan

```
romtag@4 flags=80 ver=7 type=9 pri=0
  name[1e]='identify.library' idstr[2f]='identify.library 7.3 (30.8.97)\r\n' init=a8 endskip=2ea4
  inittab: datasize=2c functab@b8 datatab@e0 initfunc=100
  functab: 9 vectors (abs-long)
    LVO -6   -> 01b2
    LVO -12  -> 01c0
    LVO -18  -> 01da
    LVO -24  -> 0258
    LVO -30  -> 02ba
    LVO -36  -> 18ee
    LVO -42  -> 12a4
    LVO -48  -> 2a4e
    LVO -54  -> 1938

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
