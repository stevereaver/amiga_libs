---
type: Library
title: rxasl_17.5.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:56.325776Z
---

# rxasl_17.5.library

## Structure scan

```
romtag@4 flags=80 ver=17 type=9 pri=0
  name[52]='' idstr[1e]='rxasl.library 17.5 (20.5.2004)\r\n' init=40 endskip=390
  inittab: datasize=22 functab@50 datatab@64 initfunc=a0
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
