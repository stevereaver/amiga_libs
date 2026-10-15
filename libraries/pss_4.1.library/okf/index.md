---
type: Library
title: pss_4.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:05.875465Z
---

# pss_4.1.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[1e]='ss.library' idstr[2f]='Special Support Library 4.1\n(c) 1993,1994 MJSoft System Software' init=70 endskip=2514
  inittab: datasize=8c functab@ac datatab@80 initfunc=136
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
