---
type: Library
title: resource_44.102(WB3.5).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:22:04.323372Z
---

# resource_44.102(WB3.5).library

## Structure scan

```
romtag@4 flags=80 ver=44 type=9 pri=0
  name[b4]='ÿôJ\xadÿôf: Jp' idstr[c6]='r' init=1e endskip=4e
  inittab: datasize=22 functab@80 datatab@2e initfunc=88
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
