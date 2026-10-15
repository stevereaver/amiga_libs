---
type: Library
title: req_2.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:59.471775Z
---

# req_2.1.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[1e]='req.library' idstr[2a]='ReqLibrary 2.1 (Sun Aug 19 1990)\r\n' init=ba endskip=127c
  inittab: datasize=48 functab@ca datatab@152 initfunc=172
  functab: 33 vectors (abs-long)
    LVO -6   -> 02bc
    LVO -12  -> 02ca
    LVO -18  -> 02de
    LVO -24  -> 030e
    LVO -30  -> 0312
    LVO -36  -> 03b8
    LVO -42  -> 03e4
    LVO -48  -> 040e
    LVO -54  -> 09ee
    LVO -60  -> 11a0
    LVO -66  -> 022c
    LVO -72  -> 022c
    LVO -78  -> 022c
    LVO -84  -> 2c18
    LVO -90  -> 3188
    LVO -96  -> 0ee0
    LVO -102 -> 0984
    LVO -108 -> 0f26
    LVO -114 -> 14f6
    LVO -120 -> 10b6
    LVO -126 -> 08c6
    LVO -132 -> 0a4c
    LVO -138 -> 0ad4
    LVO -144 -> 10e2
    LVO -150 -> 10f0
    LVO -156 -> 10fe
    LVO -162 -> 0bd8
    LVO -168 -> 3b1e
    LVO -174 -> 0444
    LVO -180 -> 0b84
    LVO -186 -> 1114
    LVO -192 -> 31a2
    LVO -198 -> 0b4a

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
