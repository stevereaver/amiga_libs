---
type: Library
title: trueaga_4.3beta.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:30.630126Z
---

# trueaga_4.3beta.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[1e]='trueaga.library' idstr[2f]='trueaga.library 4.3beta (11.10.2) (c)2001-2002 Exploder <exploder@nm.ru>\r\n' init=7a endskip=34
  inittab: datasize=30 functab@8a datatab@e2 initfunc=102
  functab: 21 vectors (abs-long)
    LVO -6   -> 0112
    LVO -12  -> 0120
    LVO -18  -> 0134
    LVO -24  -> 0178
    LVO -30  -> 034c
    LVO -36  -> 04cc
    LVO -42  -> 0548
    LVO -48  -> 0b1e
    LVO -54  -> 017c
    LVO -60  -> 01c4
    LVO -66  -> 01f0
    LVO -72  -> 022c
    LVO -78  -> 024c
    LVO -84  -> 029c
    LVO -90  -> 02d8
    LVO -96  -> 031c
    LVO -102 -> 4ede
    LVO -108 -> 4750
    LVO -114 -> 47c0
    LVO -120 -> 487e
    LVO -126 -> 48b0

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
