---
type: Library
title: xpkFRHT_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:48:56.663870Z
---

# xpkFRHT_1.0.library

## Structure scan

```
romtag@10 flags=80 ver=1 type=9 pri=0
  name[2a]='xpkFRHT.library' idstr[3a]="xpkFRHT.library Version 1.0(2 Sep'94) © Sebastiam Mulenke" init=74 endskip=1c5c
  inittab: datasize=2a functab@84 datatab@b0 initfunc=d0
  functab: 10 vectors (abs-long)
    LVO -6   -> 02f8
    LVO -12  -> 0306
    LVO -18  -> 0318
    LVO -24  -> 0350
    LVO -30  -> 023e
    LVO -36  -> 0244
    LVO -42  -> 02ae
    LVO -48  -> 02d0
    LVO -54  -> 02d2
    LVO -60  -> 02f6

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
