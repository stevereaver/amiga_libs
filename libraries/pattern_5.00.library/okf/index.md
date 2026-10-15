---
type: Library
title: pattern_5.00.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:24.471694Z
---

# pattern_5.00.library

## Structure scan

```
romtag@4 flags=00 ver=5 type=9 pri=0
  name[1e]='pattern.library' idstr[2e]='pattern.library 5.00 (28 Jan 1992)\r\n' init=54 endskip=54
  inittab: datasize=2f0848e7 functab@3f3e2c79 datatab@4 initfunc=49f90000

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
