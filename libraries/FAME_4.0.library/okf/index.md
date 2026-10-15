---
type: Library
title: FAME_4.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:55.385065Z
---

# FAME_4.0.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[1e]='FAME.library' idstr[2b]='FAME 4.00 (12.8.96)' init=60 endskip=1e58
  inittab: datasize=9c functab@70 datatab@15c initfunc=180
  functab: 58 vectors (abs-long)
    LVO -6   -> 0218
    LVO -12  -> 0284
    LVO -18  -> 0298
    LVO -24  -> 02f4
    LVO -30  -> 1cac
    LVO -36  -> 1adc
    LVO -42  -> 1b38
    LVO -48  -> 0bd0
    LVO -54  -> 0e3c
    LVO -60  -> 113c
    LVO -66  -> 1b70
    LVO -72  -> 1c60
    LVO -78  -> 1c74
    LVO -84  -> 1cf8
    LVO -90  -> 05c0
    LVO -96  -> 0838
    LVO -102 -> 08d4
    LVO -108 -> 0d9c
    LVO -114 -> 1a9c
    LVO -120 -> 0c78
    LVO -126 -> 07e4
    LVO -132 -> 0800
    LVO -138 -> 1b9c
    LVO -144 -> 1c18
    LVO -150 -> 1b84
    LVO -156 -> 02f8
    LVO -162 -> 0348
    LVO -168 -> 0384
    LVO -174 -> 1290
    LVO -180 -> 04b8
    LVO -186 -> 04b8
    LVO -192 -> 04b8
    LVO -198 -> 1d68
    LVO -204 -> 04d4
    LVO -210 -> 0d8c
    LVO -216 -> 1518
    LVO -222 -> 1ad4
    LVO -228 -> 1ad8
    LVO -234 -> 04c8
    LVO -240 -> 1d5c
    LVO -246 -> 0d14
    LVO -252 -> 0fe4
    LVO -258 -> 0cf8
    LVO -264 -> 1af8
    LVO -270 -> 1b08
    LVO -276 -> 1158
    LVO -282 -> 0d8c
    LVO -288 -> 06f0
    LVO -294 -> 1810
    LVO -300 -> 0900
    LVO -306 -> 1888
    LVO -312 -> 1d3c
    LVO -318 -> 1d1c
    LVO -324 -> 0a80
    LVO -330 -> 0cf8
    LVO -336 -> 115a
    LVO -342 -> 12a0
    LVO -348 -> 1dfc

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
