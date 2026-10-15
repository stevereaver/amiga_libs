---
type: Library
title: gadutil_36.59.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:23.432412Z
---

# gadutil_36.59.library

## Structure scan

```
romtag@4 flags=80 ver=36 type=9 pri=0
  name[c2]='gadutil.library' idstr[d2]='gadutil 36.59 (08.02.96)\r\n' init=1e endskip=c2
  inittab: datasize=40 functab@2e datatab@a2 initfunc=186
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
