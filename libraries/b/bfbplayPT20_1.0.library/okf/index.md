---
type: Library
title: bfbplayPT20_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:06:27.177027Z
---

# bfbplayPT20_1.0.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='bfbplayPT20.library' idstr[32]='bfbplayPT20.library V1.0 (02.08.1996)\r\n' init=10a endskip=194c
  inittab: datasize=b2 functab@11a datatab@156 initfunc=176
  functab: 14 vectors (abs-long)
    LVO -6   -> 01a8
    LVO -12  -> 01b6
    LVO -18  -> 01ca
    LVO -24  -> 0210
    LVO -30  -> 0214
    LVO -36  -> 0404
    LVO -42  -> 0484
    LVO -48  -> 04f2
    LVO -54  -> 052a
    LVO -60  -> 0552
    LVO -66  -> 0590
    LVO -72  -> 05be
    LVO -78  -> 05ca
    LVO -84  -> 062a

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
