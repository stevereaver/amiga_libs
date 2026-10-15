---
type: Library
title: bfbplayP60A_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:22:03.249411Z
---

# bfbplayP60A_1.0.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='bfbplayP60A.library' idstr[32]='bfbplayP60A.library V1.0 (07.07.1996)\r\n' init=98 endskip=2140
  inittab: datasize=b2 functab@a8 datatab@e4 initfunc=104
  functab: 14 vectors (abs-long)
    LVO -6   -> 0126
    LVO -12  -> 0134
    LVO -18  -> 0148
    LVO -24  -> 018e
    LVO -30  -> 0192
    LVO -36  -> 046a
    LVO -42  -> 04ea
    LVO -48  -> 054e
    LVO -54  -> 0586
    LVO -60  -> 05aa
    LVO -66  -> 05b6
    LVO -72  -> 05c2
    LVO -78  -> 05ce
    LVO -84  -> 05da

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
