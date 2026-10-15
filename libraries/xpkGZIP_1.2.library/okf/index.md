---
type: Library
title: xpkGZIP_1.2.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:25.638846Z
---

# xpkGZIP_1.2.library

## Structure scan

```
romtag@16a flags=80 ver=1 type=9 pri=0
  name[c2]='xpkGZIP.library' idstr[d2]='xpkGZIP 1.2 (14.8.2003) by Gunther Nikl (using zlib 1.1.4)\r\n' init=15a endskip=184
  inittab: datasize=2c functab@12e datatab@110 initfunc=84
  functab: 10 vectors (abs-long)
    LVO -6   -> 0072
    LVO -12  -> 0048
    LVO -18  -> 0008
    LVO -24  -> 0004
    LVO -30  -> 03f6
    LVO -36  -> 04b2
    LVO -42  -> 058c
    LVO -48  -> 052c
    LVO -54  -> 0542
    LVO -60  -> 058c

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
