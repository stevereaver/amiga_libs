---
type: Library
title: amisslmaster_4.12.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:48:55.298525Z
---

# amisslmaster_4.12.library

## Structure scan

```
romtag@a0 flags=80 ver=4 type=9 pri=0
  name[12]='amisslmaster.library' idstr[2d]='amisslmaster.library 4.12 (11.2.2022) os3-68020 version\r\n' init=90 endskip=ba
  inittab: datasize=66 functab@68 datatab@0 initfunc=ee
  functab: 9 vectors (abs-long)
    LVO -6   -> 0330
    LVO -12  -> 04b8
    LVO -18  -> 05c8
    LVO -24  -> 05fa
    LVO -30  -> 1a38
    LVO -36  -> 0c30
    LVO -42  -> 143c
    LVO -48  -> 14e0
    LVO -54  -> 1a5c

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
