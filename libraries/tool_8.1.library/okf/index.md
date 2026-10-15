---
type: Library
title: tool_8.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:48.652013Z
---

# tool_8.1.library

## Structure scan

```
romtag@38 flags=80 ver=8 type=9 pri=0
  name[54]='tool.library' idstr[62]='\r\n tool.library 8.1 (20-Jan-1991) © Copyright 1990-91 Jaba Development.\r\n Written with the Devpac Assembler version 2.14 by Jan van den Baard.\r\n\r\n' init=12a endskip=52
  inittab: datasize=36 functab@13a datatab@206 initfunc=232
  functab: 50 vectors (abs-long)
    LVO -6   -> 02e8
    LVO -12  -> 02f6
    LVO -18  -> 030a
    LVO -24  -> 0360
    LVO -30  -> 1800
    LVO -36  -> 1880
    LVO -42  -> 18be
    LVO -48  -> 1902
    LVO -54  -> 18fc
    LVO -60  -> 1902
    LVO -66  -> 193e
    LVO -72  -> 19c6
    LVO -78  -> 1a5c
    LVO -84  -> 0940
    LVO -90  -> 09dc
    LVO -96  -> 1330
    LVO -102 -> 133e
    LVO -108 -> 1366
    LVO -114 -> 13ce
    LVO -120 -> 1414
    LVO -126 -> 145a
    LVO -132 -> 158a
    LVO -138 -> 15a6
    LVO -144 -> 15fc
    LVO -150 -> 160e
    LVO -156 -> 16ce
    LVO -162 -> 1700
    LVO -168 -> 1732
    LVO -174 -> 1764
    LVO -180 -> 1796
    LVO -186 -> 17cc
    LVO -192 -> 0f90
    LVO -198 -> 11b0
    LVO -204 -> 1258
    LVO -210 -> 12e6
    LVO -216 -> 0aa8
    LVO -222 -> 0ac6
    LVO -228 -> 0b34
    LVO -234 -> 0bfe
    LVO -240 -> 0c8a
    LVO -246 -> 0c9e
    LVO -252 -> 0370
    LVO -258 -> 03f8
    LVO -264 -> 04ca
    LVO -270 -> 04ea
    LVO -276 -> 050c
    LVO -282 -> 09ec
    LVO -288 -> 0a7c
    LVO -294 -> 2be8
    LVO -300 -> 3410

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
