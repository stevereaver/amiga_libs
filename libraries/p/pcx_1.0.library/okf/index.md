---
type: Library
title: pcx_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:10:49.022814Z
---

# pcx_1.0.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='pcx.library' idstr[2a]='pcx.library 1.0 (28.11.96) ©1996 By Jim Drew.' init=58 endskip=2d2
  inittab: datasize=22 functab@68 datatab@148 initfunc=168
  functab: 55 vectors (abs-long)
    LVO -6   -> 020c
    LVO -12  -> 021a
    LVO -18  -> 0230
    LVO -24  -> 02ce
    LVO -30  -> 0330
    LVO -36  -> 0370
    LVO -42  -> 0370
    LVO -48  -> 0370
    LVO -54  -> 0370
    LVO -60  -> 0370
    LVO -66  -> 0370
    LVO -72  -> 0370
    LVO -78  -> 0370
    LVO -84  -> 0370
    LVO -90  -> 0370
    LVO -96  -> 0370
    LVO -102 -> 0370
    LVO -108 -> 0370
    LVO -114 -> 0370
    LVO -120 -> 0370
    LVO -126 -> 0370
    LVO -132 -> 0370
    LVO -138 -> 0372
    LVO -144 -> 0372
    LVO -150 -> 0372
    LVO -156 -> 0372
    LVO -162 -> 0372
    LVO -168 -> 0372
    LVO -174 -> 0372
    LVO -180 -> 0372
    LVO -186 -> 0372
    LVO -192 -> 0372
    LVO -198 -> 0372
    LVO -204 -> 0372
    LVO -210 -> 0372
    LVO -216 -> 0372
    LVO -222 -> 0372
    LVO -228 -> 0372
    LVO -234 -> 0372
    LVO -240 -> 0372
    LVO -246 -> 0372
    LVO -252 -> 0372
    LVO -258 -> 0372
    LVO -264 -> 0372
    LVO -270 -> 0372
    LVO -276 -> 0372
    LVO -282 -> 0372
    LVO -288 -> 0372
    LVO -294 -> 0372
    LVO -300 -> 0380
    LVO -306 -> 0390
    LVO -312 -> 03a0
    LVO -318 -> 0650
    LVO -324 -> 0cd0
    LVO -330 -> 1760

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
