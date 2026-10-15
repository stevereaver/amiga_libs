---
type: Library
title: asl_37.27.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:13.058626Z
---

# asl_37.27.library

## Structure scan

```
romtag@4 flags=80 ver=37 type=9 pri=0
  name[1e]='asl.library' idstr[2a]='asl 37.27 (29.4.91)\r\n' init=a0 endskip=1e
  inittab: datasize=40 functab@180 datatab@b0 initfunc=d4
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
