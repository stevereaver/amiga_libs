---
type: Library
title: diskfont_45.8.037(020)(bugged).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:50.420775Z
---

# diskfont_45.8.037(020)(bugged).library

## Structure scan

```
romtag@4 flags=84 ver=45 type=9 pri=136
  name[1e]='diskfont.library' idstr[2f]='diskfont 45.8.037 (07.12.2012)\r\n' init=3168 endskip=50
  inittab: datasize=5d4 functab@33ea datatab@33be initfunc=3178
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
