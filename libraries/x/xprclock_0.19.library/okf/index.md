---
type: Library
title: xprclock_0.19.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:20:00.800217Z
---

# xprclock_0.19.library

## Structure scan

```
romtag@8 flags=80 ver=0 type=9 pri=0
  name[22]='xprclock.library' idstr[33]='Xpr for Atomic Clock time retreival (26 Sep 1992)\r\n' init=68 endskip=1ac
  inittab: datasize=26 functab@78 datatab@a4 initfunc=c4
  functab: 10 vectors (abs-long)
    LVO -6   -> 00e6
    LVO -12  -> 00f4
    LVO -18  -> 0108
    LVO -24  -> 0148
    LVO -30  -> 014c
    LVO -36  -> 015c
    LVO -42  -> 016c
    LVO -48  -> 017c
    LVO -54  -> 018c
    LVO -60  -> 019c

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
