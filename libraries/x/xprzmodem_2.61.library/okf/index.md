---
type: Library
title: xprzmodem_2.61.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:33.446136Z
---

# xprzmodem_2.61.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[0]='p' idstr[12]='' init=64 endskip=1e
  inittab: datasize=90008 functab@2b7c0000 datatab@a initfunc=1b7c0006

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
