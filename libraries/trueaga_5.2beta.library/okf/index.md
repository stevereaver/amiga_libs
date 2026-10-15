---
type: Library
title: trueaga_5.2beta.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:30.985216Z
---

# trueaga_5.2beta.library

## Structure scan

```
romtag@4 flags=80 ver=5 type=9 pri=0
  name[1e]='trueaga.library' idstr[2f]='trueaga.library 5.2beta (20.8.3) (c)2001-2003 Exploder <exploder@nm.ru>\r\n' init=7a endskip=34
  inittab: datasize=30 functab@8a datatab@e6 initfunc=106
  functab: 22 vectors (abs-long)
    LVO -6   -> 0116
    LVO -12  -> 0124
    LVO -18  -> 0138
    LVO -24  -> 017c
    LVO -30  -> 0386
    LVO -36  -> 04f4
    LVO -42  -> 0558
    LVO -48  -> 0b36
    LVO -54  -> 0180
    LVO -60  -> 01ca
    LVO -66  -> 01f8
    LVO -72  -> 0236
    LVO -78  -> 0258
    LVO -84  -> 02aa
    LVO -90  -> 02e8
    LVO -96  -> 032e
    LVO -102 -> 4eca
    LVO -108 -> 4770
    LVO -114 -> 47da
    LVO -120 -> 4898
    LVO -126 -> 48ca
    LVO -132 -> 0360

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
