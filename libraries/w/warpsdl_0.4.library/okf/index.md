---
type: Library
title: warpsdl_0.4.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:28:03.671922Z
---

# warpsdl_0.4.library

## Structure scan

```
romtag@4 flags=80 ver=0 type=9 pri=0
  name[1dc]='B\x80 t\x08V+h' idstr[1ec]='+h' init=1e endskip=4e
  inittab: datasize=1c4 functab@78 datatab@2e initfunc=64d4
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
