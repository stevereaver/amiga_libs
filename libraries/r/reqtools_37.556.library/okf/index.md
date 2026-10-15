---
type: Library
title: reqtools_37.556.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:13.872796Z
---

# reqtools_37.556.library

## Structure scan

```
romtag@32 flags=80 ver=37 type=9 pri=0
  name[4]='reqtools.library' idstr[15]='reqtools 37.556 (15.9.91)\r\n' init=78 endskip=78
  inittab: datasize=3e functab@1d6 datatab@4c initfunc=d8
  functab: 23 vectors (abs-long)
    LVO -6   -> 0148
    LVO -12  -> 0156
    LVO -18  -> 0168
    LVO -24  -> 01d2
    LVO -30  -> 16ec
    LVO -36  -> 1920
    LVO -42  -> 18fc
    LVO -48  -> 193a
    LVO -54  -> 1a9a
    LVO -60  -> 1a78
    LVO -66  -> 02b4
    LVO -72  -> 025e
    LVO -78  -> 0270
    LVO -84  -> 023e
    LVO -90  -> 0236
    LVO -96  -> 1a9a
    LVO -102 -> 47b4
    LVO -108 -> 02c8
    LVO -114 -> 02cc
    LVO -120 -> 546e
    LVO -126 -> 0360
    LVO -132 -> 02ec
    LVO -138 -> 0330

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
