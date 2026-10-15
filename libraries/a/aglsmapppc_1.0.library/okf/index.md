---
type: Library
title: aglsmapppc_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:28:00.869561Z
---

# aglsmapppc_1.0.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[120]='\x94®\x05Ä`\x1e |' idstr[134]='' init=1e endskip=4e
  inittab: datasize=24 functab@50 datatab@2e initfunc=200
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
