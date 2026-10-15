---
type: Library
title: req_2.5.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:18.527556Z
---

# req_2.5.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[1e]='req.library' idstr[2a]='ReqLibrary 2.5 (Tue Oct  9 1990)\r\n' init=ba endskip=13a0
  inittab: datasize=48 functab@ca datatab@152 initfunc=172
  functab: 33 vectors (abs-long)
    LVO -6   -> 02bc
    LVO -12  -> 02ca
    LVO -18  -> 02de
    LVO -24  -> 030e
    LVO -30  -> 0312
    LVO -36  -> 03bc
    LVO -42  -> 03e8
    LVO -48  -> 0412
    LVO -54  -> 0a08
    LVO -60  -> 127c
    LVO -66  -> 022c
    LVO -72  -> 022c
    LVO -78  -> 022c
    LVO -84  -> 2d66
    LVO -90  -> 32f0
    LVO -96  -> 0fae
    LVO -102 -> 099a
    LVO -108 -> 0ff4
    LVO -114 -> 1628
    LVO -120 -> 1192
    LVO -126 -> 08da
    LVO -132 -> 0a76
    LVO -138 -> 0afe
    LVO -144 -> 11be
    LVO -150 -> 11cc
    LVO -156 -> 11da
    LVO -162 -> 0c20
    LVO -168 -> 3c00
    LVO -174 -> 0448
    LVO -180 -> 0bcc
    LVO -186 -> 11f0
    LVO -192 -> 3310
    LVO -198 -> 0b92

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
