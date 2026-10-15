---
type: Library
title: systemplus_95.5.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:22:01.182975Z
---

# systemplus_95.5.library

## Structure scan

```
romtag@4 flags=80 ver=95 type=9 pri=0
  name[d2]='systemplus.library' idstr[24]='systemplus 95.5 (25.5.95)\r\n© 1995 Ian J. Einman' init=114 endskip=200c
  inittab: datasize=6c functab@124 datatab@1f8 initfunc=218
  functab: 52 vectors (abs-long)
    LVO -6   -> 02ea
    LVO -12  -> 02f8
    LVO -18  -> 030c
    LVO -24  -> 0384
    LVO -30  -> 07f6
    LVO -36  -> 088c
    LVO -42  -> 087c
    LVO -48  -> 08fc
    LVO -54  -> 0996
    LVO -60  -> 0cf0
    LVO -66  -> 0388
    LVO -72  -> 0fc6
    LVO -78  -> 1072
    LVO -84  -> 11c6
    LVO -90  -> 1230
    LVO -96  -> 1362
    LVO -102 -> 13fc
    LVO -108 -> 1466
    LVO -114 -> 1496
    LVO -120 -> 1474
    LVO -126 -> 14a6
    LVO -132 -> 153a
    LVO -138 -> 14d6
    LVO -144 -> 150c
    LVO -150 -> 15f6
    LVO -156 -> 16f0
    LVO -162 -> 1266
    LVO -168 -> 0430
    LVO -174 -> 05a0
    LVO -180 -> 07ba
    LVO -186 -> 07d2
    LVO -192 -> 172c
    LVO -198 -> 1890
    LVO -204 -> 1ac8
    LVO -210 -> 1ba6
    LVO -216 -> 1da0
    LVO -222 -> 1da2
    LVO -228 -> 1e46
    LVO -234 -> 1e9e
    LVO -240 -> 1b04
    LVO -246 -> 0816
    LVO -252 -> 1f92
    LVO -258 -> 1fec
    LVO -264 -> 090a
    LVO -270 -> 0e7e
    LVO -276 -> 1576
    LVO -282 -> 1562
    LVO -288 -> 1032
    LVO -294 -> 104c
    LVO -300 -> 158a
    LVO -306 -> 159e
    LVO -312 -> 144c

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
