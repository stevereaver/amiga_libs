---
type: Library
title: layers_45.24.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:42.145710Z
---

# layers_45.24.library

## Structure scan

```
romtag@4 flags=81 ver=45 type=9 pri=64
  name[1c0]='layers.library' idstr[1cf]='layers.library 45.24 (31.10.2014)\r\n' init=1e endskip=347c
  inittab: datasize=3c functab@52 datatab@32 initfunc=b2
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
