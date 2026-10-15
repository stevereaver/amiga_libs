---
type: Library
title: reqtools_37.600.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:16.326396Z
---

# reqtools_37.600.library

## Structure scan

```
romtag@30 flags=80 ver=37 type=9 pri=0
  name[4]='reqtools.library' idstr[15]='reqtools 37.600 (7.3.92)\r\n' init=78 endskip=76
  inittab: datasize=3e functab@20c datatab@4a initfunc=ec
  functab: 23 vectors (abs-long)
    LVO -6   -> 0174
    LVO -12  -> 0182
    LVO -18  -> 0194
    LVO -24  -> 0208
    LVO -30  -> 1910
    LVO -36  -> 1b48
    LVO -42  -> 1b24
    LVO -48  -> 1b62
    LVO -54  -> 1cc2
    LVO -60  -> 1ca0
    LVO -66  -> 02f2
    LVO -72  -> 0294
    LVO -78  -> 02aa
    LVO -84  -> 0274
    LVO -90  -> 026c
    LVO -96  -> 1cc2
    LVO -102 -> 4a4c
    LVO -108 -> 030a
    LVO -114 -> 030e
    LVO -120 -> 5706
    LVO -126 -> 03a2
    LVO -132 -> 032e
    LVO -138 -> 0372

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
