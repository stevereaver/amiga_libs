---
type: Library
title: req_2.7.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:21.254215Z
---

# req_2.7.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[1e]='req.library' idstr[2e]='ReqLibrary 2.7 (Mon May 25 1992)\r\n' init=de endskip=13ee
  inittab: datasize=4c functab@ee datatab@182 initfunc=1a2
  functab: 36 vectors (abs-long)
    LVO -6   -> 02f2
    LVO -12  -> 0300
    LVO -18  -> 0314
    LVO -24  -> 0344
    LVO -30  -> 0348
    LVO -36  -> 03f2
    LVO -42  -> 041e
    LVO -48  -> 0448
    LVO -54  -> 0a42
    LVO -60  -> 12c6
    LVO -66  -> 0262
    LVO -72  -> 0262
    LVO -78  -> 0262
    LVO -84  -> 2db6
    LVO -90  -> 3340
    LVO -96  -> 0ff8
    LVO -102 -> 09d4
    LVO -108 -> 103e
    LVO -114 -> 1678
    LVO -120 -> 11dc
    LVO -126 -> 0910
    LVO -132 -> 0ac0
    LVO -138 -> 0b48
    LVO -144 -> 1208
    LVO -150 -> 1216
    LVO -156 -> 1224
    LVO -162 -> 0c6a
    LVO -168 -> 3c50
    LVO -174 -> 047e
    LVO -180 -> 0c16
    LVO -186 -> 123a
    LVO -192 -> 3360
    LVO -198 -> 0bdc
    LVO -204 -> 1310
    LVO -210 -> 1310
    LVO -216 -> 1310

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
