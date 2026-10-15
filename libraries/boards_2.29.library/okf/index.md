---
type: Library
title: boards_2.29.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:41.799320Z
---

# boards_2.29.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[1e]='boards.library' idstr[2e]='$VER: boards.library 2.29 (11-Jan-2001) ©2001 by Thomas Barth' init=a0 endskip=350a
  inittab: datasize=22 functab@b0 datatab@c6 initfunc=e6
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
