---
type: Library
title: qfont_39.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:18.668266Z
---

# qfont_39.0.library

## Structure scan

```
romtag@74 flags=80 ver=39 type=9 pri=0
  name[66]='qfont.library' idstr[4e]='QFont 39.0 (02.03.93)\r\n' init=8e endskip=fc7
  inittab: datasize=7e functab@9e datatab@0 initfunc=108
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
