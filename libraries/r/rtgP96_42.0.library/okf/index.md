---
type: Library
title: rtgP96_42.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:47.915806Z
---

# rtgP96_42.0.library

## Structure scan

```
romtag@4 flags=80 ver=42 type=9 pri=0
  name[1b4]='N]NuNuNUÿp/\x0eJ¹' idstr[1c4]='' init=1e endskip=4e
  inittab: datasize=50 functab@50 datatab@2e initfunc=50
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
