---
type: Library
title: newgui_0.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:28:04.712568Z
---

# newgui_0.1.library

## Structure scan

```
romtag@7594 flags=80 ver=1 type=9 pri=0
  name[75ae]='newgui.library' idstr[75be]='newgui.library 0.1 4-August-2003\r\n' init=75e4 endskip=75e2
  inittab: datasize=5a functab@75f4 datatab@7740 initfunc=776c
  functab: 82 vectors (abs-long)
    LVO -6   -> 78d8
    LVO -12  -> 78e8
    LVO -18  -> 7904
    LVO -24  -> 799c
    LVO -30  -> 0b50
    LVO -36  -> 1228
    LVO -42  -> 066e
    LVO -48  -> 06f6
    LVO -54  -> 13ac
    LVO -60  -> 1aa0
    LVO -66  -> 1be8
    LVO -72  -> 20b2
    LVO -78  -> 2720
    LVO -84  -> 28c6
    LVO -90  -> 29ae
    LVO -96  -> 2b9a
    LVO -102 -> 2c4a
    LVO -108 -> 2caa
    LVO -114 -> 2eb0
    LVO -120 -> 3b30
    LVO -126 -> 2ef0
    LVO -132 -> 31f0
    LVO -138 -> 377c
    LVO -144 -> 371e
    LVO -150 -> 37da
    LVO -156 -> 07da
    LVO -162 -> 3038
    LVO -168 -> 30ac
    LVO -174 -> 3132
    LVO -180 -> 3ec2
    LVO -186 -> 10ba
    LVO -192 -> 11b0
    LVO -198 -> 5894
    LVO -204 -> 6bd2
    LVO -210 -> 2aba
    LVO -216 -> 42b2
    LVO -222 -> 47c4
    LVO -228 -> 487c
    LVO -234 -> 22b8
    LVO -240 -> 4548
    LVO -246 -> 45c0
    LVO -252 -> 46c8
    LVO -258 -> 4782
    LVO -264 -> 4570
    LVO -270 -> 4598
    LVO -276 -> 2012
    LVO -282 -> 2062
    LVO -288 -> 1d22
    LVO -294 -> 4934
    LVO -300 -> 4ae6
    LVO -306 -> 4bde
    LVO -312 -> 50be
    LVO -318 -> 50fc
    LVO -324 -> 4d9c
    LVO -330 -> 5408
    LVO -336 -> 5468
    LVO -342 -> 513a
    LVO -348 -> 54c8
    LVO -354 -> 552a
    LVO -360 -> 558c
    LVO -366 -> 5714
    LVO -372 -> 156e
    LVO -378 -> 16a6
    LVO -384 -> 0e9e
    LVO -390 -> 059c
    LVO -396 -> 04ec
    LVO -402 -> 061c
    LVO -408 -> 6510
    LVO -414 -> 5c2a
    LVO -420 -> 5e5e
    LVO -426 -> 6124
    LVO -432 -> 63e4
    LVO -438 -> 4a18
    LVO -444 -> 081c
    LVO -450 -> 0994
    LVO -456 -> 68c8
    LVO -462 -> 441c
    LVO -468 -> 44c4
    LVO -474 -> 434c
    LVO -480 -> 6968
    LVO -486 -> 69ae
    LVO -492 -> 6ac0

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
