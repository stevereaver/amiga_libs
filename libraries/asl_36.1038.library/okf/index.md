---
type: Library
title: asl_36.1038.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:09.306782Z
---

# asl_36.1038.library

## Structure scan

```
romtag@4 flags=80 ver=36 type=9 pri=0
  name[1e]='asl.library' idstr[2a]='ASL 36.1038 6/7/90\n' init=9e endskip=1e
  inittab: datasize=40 functab@180 datatab@ae initfunc=d2
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
