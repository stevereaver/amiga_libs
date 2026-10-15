---
type: Library
title: datatypes_40.6(WB3.1).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:55.959277Z
---

# datatypes_40.6(WB3.1).library

## Structure scan

```
romtag@4 flags=80 ver=40 type=9 pri=0
  name[1e]='datatypes.library' idstr[30]='DataTypes 40.6 (25.8.93)\r\n' init=4c endskip=350c
  inittab: datasize=234 functab@5c datatab@8e initfunc=cc
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
