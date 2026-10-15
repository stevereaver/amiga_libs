---
type: Library
title: iffparse_37.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:48:58.068886Z
---

# iffparse_37.1.library

## Structure scan

```
romtag@4 flags=00 ver=37 type=9 pri=0
  name[58]='iffparse.library' idstr[69]='iffparse.library 37.1 (18 Jan 1991)\r\n' init=16c endskip=a5
  inittab: datasize=4e55fff8 functab@48e70122 datatab@2e082f0e initfunc=43f90000

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
