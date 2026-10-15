---
type: Library
title: bullet_44.1(WB3.5).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:21.518132Z
---

# bullet_44.1(WB3.5).library

## Structure scan

```
romtag@0 flags=81 ver=44 type=9 pri=136
  name[1a]='bullet.library' idstr[29]='bullet 44.1 (1.5.99)\r\n' init=5f2c endskip=6724
  inittab: datasize=64 functab@5efc datatab@5f14 initfunc=5f60
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
