---
type: Library
title: fblit_1.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:15.316594Z
---

# fblit_1.1.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='fblit.library' idstr[74]='fblit.library 1.1 (10.11.2017)' init=94 endskip=442c
  inittab: datasize=5a functab@a4 datatab@108 initfunc=128
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
