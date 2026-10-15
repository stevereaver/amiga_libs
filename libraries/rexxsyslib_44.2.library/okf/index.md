---
type: Library
title: rexxsyslib_44.2.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:59.823107Z
---

# rexxsyslib_44.2.library

## Structure scan

```
romtag@4 flags=80 ver=44 type=9 pri=0
  name[54d7]='rexxsyslib.library' idstr[54ea]='rexxsyslib 44.2 (14.03.2004)\r\n' init=20 endskip=821c
  inittab: datasize=fc functab@30 datatab@d2 initfunc=524e
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
