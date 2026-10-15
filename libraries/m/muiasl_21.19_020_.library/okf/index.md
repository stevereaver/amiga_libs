---
type: Library
title: muiasl_21.19(020).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:38.053519Z
---

# muiasl_21.19(020).library

## Structure scan

```
romtag@f2 flags=80 ver=21 type=9 pri=0
  name[4]='muiasl.library' idstr[19]='muiasl.library 21.19 (21.12.2020) Copyright (C) 2006-2020 by Thore Boeckelmann, Jens Maus [AmigaOS3/mc68020] [svn r6714] [5.0-2020R3]\r\n' init=e2 endskip=10c
  inittab: datasize=58 functab@a2 datatab@0 initfunc=246
  functab: 15 vectors (abs-long)
    LVO -6   -> 062e
    LVO -12  -> 0796
    LVO -18  -> 03e8
    LVO -24  -> 2734
    LVO -30  -> 2640
    LVO -36  -> 267a
    LVO -42  -> 222a
    LVO -48  -> 2372
    LVO -54  -> 23d2
    LVO -60  -> 23f4
    LVO -66  -> 269c
    LVO -72  -> 26a0
    LVO -78  -> 24f0
    LVO -84  -> 2590
    LVO -90  -> 26a4

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
