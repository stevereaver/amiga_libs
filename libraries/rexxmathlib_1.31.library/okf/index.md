---
type: Library
title: rexxmathlib_1.31.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:49.283992Z
---

# rexxmathlib_1.31.library

## Structure scan

```
romtag@96a flags=80 ver=1 type=9 pri=0
  name[0]='ABS' idstr[14]='TAN2' init=25a endskip=984
  inittab: datasize=4eba0dbc functab@504f243c datatab@3ff00000 initfunc=76004eba

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
