---
type: Library
title: resource_44.103.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:10:48.686394Z
---

# resource_44.103.library

## Structure scan

```
romtag@44c flags=80 ver=44 type=9 pri=0
  name[48d]='resource.library' idstr[466]='resource.library 44.103 (28.11.2001)\r\n' init=0 endskip=49e
  inittab: datasize=701e4e75 functab@4e71696e datatab@74756974 initfunc=696f6e2e

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
