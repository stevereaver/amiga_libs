---
type: Library
title: boards_3.35.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:24.930134Z
---

# boards_3.35.library

## Structure scan

```
romtag@4 flags=80 ver=3 type=9 pri=0
  name[1e]='boards.library' idstr[2e]='$VER: boards.library 3.35  (19-Dec-2016) maintained by Marcus Gerards (marcus.gerards@gmail.com)' init=bc endskip=5aff
  inittab: datasize=22 functab@cc datatab@e4 initfunc=104
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
