---
type: Library
title: rexxsyslib_36.14.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:58.463427Z
---

# rexxsyslib_36.14.library

## Structure scan

```
romtag@4 flags=80 ver=36 type=9 pri=0
  name[54a7]='rexxsyslib.library' idstr[54ba]='rexxsyslib 36.14 (09-MAY-90)\n' init=20 endskip=81a0
  inittab: datasize=fc functab@30 datatab@d2 initfunc=523c
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
