---
type: Library
title: cdplayer_52.7(6.2.2014).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:16:12.970546Z
---

# cdplayer_52.7(6.2.2014).library

## Structure scan

```
romtag@150 flags=80 ver=52 type=9 pri=0
  name[214]='cdplayer.library' idstr[1f3]='cdplayer.library 52.7 (6.1.2014)' init=1dc endskip=170
  inittab: datasize=6e functab@170 datatab@1b8 initfunc=34
  functab: 3 vectors (abs-long)
    LVO -6   -> 012c
    LVO -12  -> 0100
    LVO -18  -> 00e0

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
