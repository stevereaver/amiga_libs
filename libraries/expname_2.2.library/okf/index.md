---
type: Library
title: expname_2.2.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:57.394700Z
---

# expname_2.2.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[1e]='expname.library' idstr[2e]='expname.library 2.2 (19.4.96)\r\n' init=a8 endskip=1dfc
  inittab: datasize=2c functab@b8 datatab@d4 initfunc=f4
  functab: 6 vectors (abs-long)
    LVO -6   -> 014a
    LVO -12  -> 0158
    LVO -18  -> 016c
    LVO -24  -> 01b4
    LVO -30  -> 06e6
    LVO -36  -> 01f6

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
