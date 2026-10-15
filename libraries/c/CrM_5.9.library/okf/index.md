---
type: Library
title: CrM_5.9.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:11.699533Z
---

# CrM_5.9.library

## Structure scan

```
romtag@4 flags=80 ver=5 type=9 pri=0
  name[1e]='CrM.library' idstr[2a]='CrM.library 5.9 (18.11.96)\r\n' init=54 endskip=26f8
  inittab: datasize=3a functab@64 datatab@a8 initfunc=c8
  functab: 16 vectors (abs-long)
    LVO -6   -> 018c
    LVO -12  -> 019a
    LVO -18  -> 01a8
    LVO -24  -> 01a8
    LVO -30  -> 0348
    LVO -36  -> 023a
    LVO -42  -> 0b2a
    LVO -48  -> 0b76
    LVO -54  -> 0d74
    LVO -60  -> 0ff0
    LVO -66  -> 117e
    LVO -72  -> 1366
    LVO -78  -> 1158
    LVO -84  -> 116a
    LVO -90  -> 1452
    LVO -96  -> 0476

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
