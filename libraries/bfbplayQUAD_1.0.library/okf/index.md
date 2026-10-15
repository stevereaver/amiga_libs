---
type: Library
title: bfbplayQUAD_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:17.991940Z
---

# bfbplayQUAD_1.0.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='bfbplayQUAD.library' idstr[32]='bfbplayQUAD.library V1.0 (13.06.1996)\r\n' init=f2 endskip=10a
  inittab: datasize=b2 functab@102 datatab@13e initfunc=15e
  functab: 14 vectors (abs-long)
    LVO -6   -> 0180
    LVO -12  -> 018e
    LVO -18  -> 01a2
    LVO -24  -> 01e8
    LVO -30  -> 01ec
    LVO -36  -> 0404
    LVO -42  -> 047c
    LVO -48  -> 04f2
    LVO -54  -> 051a
    LVO -60  -> 053e
    LVO -66  -> 056a
    LVO -72  -> 058c
    LVO -78  -> 0598
    LVO -84  -> 05f8

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
