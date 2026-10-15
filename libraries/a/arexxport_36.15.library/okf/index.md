---
type: Library
title: arexxport_36.15.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:08.946450Z
---

# arexxport_36.15.library

## Structure scan

```
romtag@4 flags=80 ver=36 type=9 pri=0
  name[1d4]='arexxport.library' idstr[1e6]='Arexxport.library 36.15 (21.11.95)\r\n' init=296 endskip=4
  inittab: datasize=22 functab@256 datatab@236 initfunc=1e
  functab: 15 vectors (abs-long)
    LVO -6   -> 004a
    LVO -12  -> 0090
    LVO -18  -> 0058
    LVO -24  -> 00a4
    LVO -30  -> 00a8
    LVO -36  -> 00c2
    LVO -42  -> 00da
    LVO -48  -> 00f2
    LVO -54  -> 0160
    LVO -60  -> 0126
    LVO -66  -> 010a
    LVO -72  -> 0142
    LVO -78  -> 017e
    LVO -84  -> 0198
    LVO -90  -> 01b2

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
