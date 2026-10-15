---
type: Library
title: tkrtools_0.29.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:59.152670Z
---

# tkrtools_0.29.library

## Structure scan

```
romtag@4 flags=80 ver=34 type=9 pri=0
  name[f0]='rary' idstr[101]='' init=e0 endskip=1e
  inittab: datasize=61727900 functab@67726170 datatab@68696373 initfunc=2e6c6962

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
