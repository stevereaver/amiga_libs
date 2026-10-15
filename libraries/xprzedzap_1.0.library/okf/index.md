---
type: Library
title: xprzedzap_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:41.363616Z
---

# xprzedzap_1.0.library

## Structure scan

```
romtag@8 flags=80 ver=1 type=9 pri=0
  name[22]='xprzedzap.library' idstr[34]='XprZedZap 1.00 (22 Dec 1992)\r\n' init=54 endskip=1a4
  inittab: datasize=26 functab@64 datatab@90 initfunc=bc
  functab: 10 vectors (abs-long)
    LVO -6   -> 00de
    LVO -12  -> 00ec
    LVO -18  -> 0100
    LVO -24  -> 0140
    LVO -30  -> 0144
    LVO -36  -> 0154
    LVO -42  -> 0164
    LVO -48  -> 0174
    LVO -54  -> 0184
    LVO -60  -> 0194

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
