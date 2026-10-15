---
type: Library
title: ptreplay_7.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:50.355696Z
---

# ptreplay_7.0.library

## Structure scan

```
romtag@4 flags=80 ver=7 type=9 pri=0
  name[1e]='ptreplay.library' idstr[2f]='ptreplay.library 7.01(2026-04-11)\r\n' init=60 endskip=320
  inittab: datasize=34 functab@70 datatab@ac initfunc=cc
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
