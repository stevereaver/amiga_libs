---
type: Library
title: guienv_38.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:44.788866Z
---

# guienv_38.1.library

## Structure scan

```
romtag@4 flags=80 ver=38 type=9 pri=0
  name[1e]='guienv.library' idstr[3e]='GUIEnv 38.1 (BETA 2 2000)\r\n' init=7e endskip=122
  inittab: datasize=22 functab@ba datatab@8e initfunc=124
  functab: 25 vectors (abs-long)
    LVO -6   -> 01cc
    LVO -12  -> 01dc
    LVO -18  -> 01f0
    LVO -24  -> 0238
    LVO -30  -> 023c
    LVO -36  -> 0254
    LVO -42  -> 02a0
    LVO -48  -> 0268
    LVO -54  -> 028c
    LVO -60  -> 02b8
    LVO -66  -> 02cc
    LVO -72  -> 02d8
    LVO -78  -> 02ec
    LVO -84  -> 0300
    LVO -90  -> 0314
    LVO -96  -> 0334
    LVO -102 -> 034c
    LVO -108 -> 0360
    LVO -114 -> 0374
    LVO -120 -> 038c
    LVO -126 -> 03a4
    LVO -132 -> 03b8
    LVO -138 -> 03d0
    LVO -144 -> 03e8
    LVO -150 -> 0400

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
