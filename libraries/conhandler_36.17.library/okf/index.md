---
type: Library
title: conhandler_36.17.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:48:54.628667Z
---

# conhandler_36.17.library

## Structure scan

```
romtag@4 flags=80 ver=36 type=9 pri=0
  name[310]='conhandler.library' idstr[323]='conhandler 36.17 (12-DEC-90)\n' init=20 endskip=1b5e
  inittab: datasize=7c functab@30 datatab@6a initfunc=96
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
