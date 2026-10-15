---
type: Library
title: prelude_5.6.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:24.247196Z
---

# prelude_5.6.library

## Structure scan

```
romtag@b18 flags=80 ver=5 type=9 pri=0
  name[b08]='prelude.library' idstr[ab3]='prelude.library 5.6 (20.10.2020)\r\n' init=be0 endskip=b32
  inittab: datasize=a8 functab@b34 datatab@bb8 initfunc=978
  functab: 20 vectors (abs-long)
    LVO -6   -> 09ac
    LVO -12  -> 09c4
    LVO -18  -> 09ec
    LVO -24  -> 0a2c
    LVO -30  -> 0de8
    LVO -36  -> 0df8
    LVO -42  -> 0e50
    LVO -48  -> 1270
    LVO -54  -> 1280
    LVO -60  -> 1444
    LVO -66  -> 1688
    LVO -72  -> 169c
    LVO -78  -> 16b0
    LVO -84  -> 19a8
    LVO -90  -> 1cf4
    LVO -96  -> 244c
    LVO -102 -> 24c4
    LVO -108 -> 29e0
    LVO -114 -> 018c
    LVO -120 -> 24f8

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
