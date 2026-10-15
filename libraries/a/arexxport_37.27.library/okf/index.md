---
type: Library
title: arexxport_37.27.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:38.719042Z
---

# arexxport_37.27.library

## Structure scan

```
romtag@4 flags=80 ver=37 type=9 pri=0
  name[228]='arexxport.library' idstr[23a]='Arexxport.library 37.27 (6.5.96)\r\n' init=2f2 endskip=4
  inittab: datasize=22 functab@2a6 datatab@286 initfunc=1e
  functab: 18 vectors (abs-long)
    LVO -6   -> 004a
    LVO -12  -> 0090
    LVO -18  -> 0058
    LVO -24  -> 00a4
    LVO -30  -> 00d0
    LVO -36  -> 00ea
    LVO -42  -> 0102
    LVO -48  -> 011a
    LVO -54  -> 0132
    LVO -60  -> 0150
    LVO -66  -> 016c
    LVO -72  -> 0188
    LVO -78  -> 01a6
    LVO -84  -> 01c0
    LVO -90  -> 01da
    LVO -96  -> 01f2
    LVO -102 -> 020a
    LVO -108 -> 00a8

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
