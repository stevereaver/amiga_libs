---
type: Library
title: desertsoftware_1.3.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:25.818482Z
---

# desertsoftware_1.3.library

## Structure scan

```
romtag@4 flags=80 ver=33 type=9 pri=0
  name[1e]='desertsoftware.library' idstr[35]='D.S.L. © Desert Software 1.3 (29th July 1992)\r\n' init=66 endskip=2b92
  inittab: datasize=74 functab@76 datatab@ba initfunc=e6
  functab: 16 vectors (abs-long)
    LVO -6   -> 012e
    LVO -12  -> 013c
    LVO -18  -> 0156
    LVO -24  -> 01c0
    LVO -30  -> 01c4
    LVO -36  -> 12e0
    LVO -42  -> 1608
    LVO -48  -> 1c7e
    LVO -54  -> 1f3c
    LVO -60  -> 1fc0
    LVO -66  -> 1fda
    LVO -72  -> 2004
    LVO -78  -> 2018
    LVO -84  -> 2098
    LVO -90  -> 20d2
    LVO -96  -> 210e

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
