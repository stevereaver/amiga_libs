---
type: Library
title: gadutil_37.10.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:41.131707Z
---

# gadutil_37.10.library

## Structure scan

```
romtag@4 flags=80 ver=37 type=9 pri=0
  name[ca]='gadutil.library' idstr[da]='gadutil 37.10 (28.09.97)\r\n' init=1e endskip=ca
  inittab: datasize=40 functab@2e datatab@aa initfunc=18e
  functab: 0 vectors (abs-long)

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
