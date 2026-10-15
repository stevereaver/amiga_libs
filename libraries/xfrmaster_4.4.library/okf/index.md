---
type: Library
title: xfrmaster_4.4.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:49.672328Z
---

# xfrmaster_4.4.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[1e]='xfrmaster.library' idstr[36]='eXternal Format Rippers master library 4.4        \n(04/19/2003, 10/2009, 7/2014) by Andreas G. Szabo <silva@psi5.com> \nall rights reserved -- www.psi5.com/~silva/afilter' init=e0 endskip=1d0c
  inittab: datasize=54 functab@110 datatab@f0 initfunc=17c
  functab: 23 vectors (abs-long)
    LVO -6   -> 01a2
    LVO -12  -> 01b0
    LVO -18  -> 01be
    LVO -24  -> 01ee
    LVO -30  -> 0204
    LVO -36  -> 0264
    LVO -42  -> 107a
    LVO -48  -> 0668
    LVO -54  -> 0bce
    LVO -60  -> 0f66
    LVO -66  -> 11d0
    LVO -72  -> 148a
    LVO -78  -> 148e
    LVO -84  -> 14e8
    LVO -90  -> 14ec
    LVO -96  -> 15ae
    LVO -102 -> 160e
    LVO -108 -> 0ba4
    LVO -114 -> 0a2c
    LVO -120 -> 14f0
    LVO -126 -> 15ee
    LVO -132 -> 0c58
    LVO -138 -> 0d90

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
