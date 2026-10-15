---
type: Library
title: xprfts_0.74.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:04.510426Z
---

# xprfts_0.74.library

## Structure scan

```
romtag@8 flags=80 ver=0 type=9 pri=0
  name[22]='xprfts.library' idstr[31]='Xpr for FTS-1/FTS-7 fidonet sessions (20 Sep 1992)\r\n' init=66 endskip=1aa
  inittab: datasize=26 functab@76 datatab@a2 initfunc=c2
  functab: 10 vectors (abs-long)
    LVO -6   -> 00e4
    LVO -12  -> 00f2
    LVO -18  -> 0106
    LVO -24  -> 0146
    LVO -30  -> 014a
    LVO -36  -> 015a
    LVO -42  -> 016a
    LVO -48  -> 017a
    LVO -54  -> 018a
    LVO -60  -> 019a

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
