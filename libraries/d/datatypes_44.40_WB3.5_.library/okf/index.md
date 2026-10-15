---
type: Library
title: datatypes_44.40(WB3.5).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:21.995011Z
---

# datatypes_44.40(WB3.5).library

## Structure scan

```
romtag@4 flags=80 ver=44 type=9 pri=0
  name[1e]='datatypes.library' idstr[30]='datatypes.library 44.40 (31.7.99)\r\n' init=d8 endskip=1e
  inittab: datasize=696e7374 functab@72756d65 datatab@6e740000 initfunc=6d757369

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
