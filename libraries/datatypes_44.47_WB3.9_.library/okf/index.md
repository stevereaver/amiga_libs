---
type: Library
title: datatypes_44.47(WB3.9).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:22.669932Z
---

# datatypes_44.47(WB3.9).library

## Structure scan

```
romtag@4 flags=80 ver=44 type=9 pri=0
  name[1e]='datatypes.library' idstr[30]='datatypes.library 44.47 (25.12.1999)\r\n' init=d8 endskip=1e
  inittab: datasize=756e6400 functab@696e7374 datatab@72756d65 initfunc=6e740000

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
