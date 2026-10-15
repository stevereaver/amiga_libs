---
type: Library
title: ptplay_2.5.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:24.474353Z
---

# ptplay_2.5.library

## Structure scan

```
romtag@0 flags=c8 ver=2 type=9 pri=0
  name[e8]='ptplay.library' idstr[c7]='ptplay.library 2.5 (25.1.2006)' init=80 endskip=20
  inittab: datasize=30 functab@90 datatab@5c initfunc=fc
  functab: 11 vectors (abs-long)
    LVO -6   -> 0178
    LVO -12  -> 014c
    LVO -18  -> 012c
    LVO -24  -> 00f8
    LVO -30  -> 020c
    LVO -36  -> 0ffc
    LVO -42  -> 028c
    LVO -48  -> 0334
    LVO -54  -> 0350
    LVO -60  -> 03fc
    LVO -66  -> 04b8

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
