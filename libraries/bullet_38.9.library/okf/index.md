---
type: Library
title: bullet_38.9.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:32.785911Z
---

# bullet_38.9.library

## Structure scan

```
romtag@0 flags=81 ver=38 type=9 pri=136
  name[1a]='bullet.library' idstr[29]='bullet 38.9 (21.5.92)\r\n' init=514 endskip=6f54
  inittab: datasize=32 functab@4e4 datatab@4fc initfunc=548
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
