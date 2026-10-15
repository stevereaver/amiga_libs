---
type: Library
title: datatypes_44.48.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:16.651014Z
---

# datatypes_44.48.library

## Structure scan

```
romtag@4 flags=80 ver=44 type=9 pri=0
  name[1e]='datatypes.library' idstr[30]='datatypes.library 44.48 (07.07.2010)\r\n' init=60 endskip=1e
  inittab: datasize=3f3e598f functab@2f0f2f08 datatab@610025d4 initfunc=508f205f

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
