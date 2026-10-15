---
type: Library
title: SimpleDT_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:51.027612Z
---

# SimpleDT_1.0.library

## Structure scan

```
romtag@12 flags=80 ver=1 type=9 pri=0
  name[49]='SimpleDT.library' idstr[2c]='SimpleDT 1.0 (18.04.2013) \r\n' init=356 endskip=356
  inittab: datasize=30 functab@30e datatab@336 initfunc=1a2
  functab: 9 vectors (abs-long)
    LVO -6   -> 0068
    LVO -12  -> 0158
    LVO -18  -> 00ac
    LVO -24  -> 005a
    LVO -30  -> 0246
    LVO -36  -> 0266
    LVO -42  -> 029e
    LVO -48  -> 02c6
    LVO -54  -> 02ee

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
