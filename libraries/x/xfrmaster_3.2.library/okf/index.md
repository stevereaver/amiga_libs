---
type: Library
title: xfrmaster_3.2.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:24:04.275683Z
---

# xfrmaster_3.2.library

## Structure scan

```
romtag@4 flags=80 ver=3 type=9 pri=0
  name[1e]='xfrmaster.library' idstr[36]='eXternal Format Rippers master library 3.2        \n(04/19/2003, 10/2009, 1/2014) by Andreas G. Szabo <silva@psi5.com> \nall rights reserved -- www.psi5.com/~silva/afilter' init=e0 endskip=19d8
  inittab: datasize=54 functab@110 datatab@f0 initfunc=174
  functab: 21 vectors (abs-long)
    LVO -6   -> 019a
    LVO -12  -> 01a8
    LVO -18  -> 01b6
    LVO -24  -> 01e6
    LVO -30  -> 01fc
    LVO -36  -> 025c
    LVO -42  -> 0d46
    LVO -48  -> 0642
    LVO -54  -> 0ba8
    LVO -60  -> 0c32
    LVO -66  -> 0e9c
    LVO -72  -> 1156
    LVO -78  -> 115a
    LVO -84  -> 11b4
    LVO -90  -> 11b8
    LVO -96  -> 127a
    LVO -102 -> 12da
    LVO -108 -> 0b7e
    LVO -114 -> 0a06
    LVO -120 -> 11bc
    LVO -126 -> 12ba

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
