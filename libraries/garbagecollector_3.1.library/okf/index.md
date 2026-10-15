---
type: Library
title: garbagecollector_3.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:14.788655Z
---

# garbagecollector_3.1.library

## Structure scan

```
romtag@4 flags=80 ver=3 type=9 pri=0
  name[5c]='garbagecollector.library' idstr[78]='garbagecollector.library 3.1 (01-Nov-93) © 1993 by Fridtjof Siebert' init=1e endskip=d3
  inittab: datasize=36 functab@bc datatab@2e initfunc=21d0
  functab: 3 vectors (abs-long)
    LVO -6   -> 2200
    LVO -12  -> 2226
    LVO -18  -> 2246

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
