---
type: Library
title: rexxkuang11_0.74.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:12.454631Z
---

# rexxkuang11_0.74.library

## Structure scan

```
romtag@4 flags=80 ver=0 type=9 pri=0
  name[544]='j\x06D\x82r-`h\x08\x07' idstr[558]='' init=1e endskip=4e
  inittab: datasize=3a functab@528 datatab@2e initfunc=ef0
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
