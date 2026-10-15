---
type: Library
title: info_1.3.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:05.268247Z
---

# info_1.3.library

## Structure scan

```
romtag@0 flags=80 ver=34 type=9 pri=0
  name[c4]='info.library' idstr[1a]='info V1.3\r\n' init=26 endskip=d2
  inittab: datasize=26 functab@6e datatab@50 initfunc=36
  functab: 5 vectors (abs-long)
    LVO -6   -> 0086
    LVO -12  -> 0092
    LVO -18  -> 009e
    LVO -24  -> 00a8
    LVO -30  -> 00aa

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
