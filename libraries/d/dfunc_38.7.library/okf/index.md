---
type: Library
title: dfunc_38.7.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:04.164966Z
---

# dfunc_38.7.library

## Structure scan

```
romtag@4 flags=80 ver=38 type=9 pri=0
  name[51]='dfunc.library' idstr[1e]='dfunc.library 38.7 (30.10.96) by Kenneth C. Nilsen' init=60 endskip=3a74
  inittab: datasize=68 functab@70 datatab@270 initfunc=292
  functab: 127 vectors (abs-long)
    LVO -6   -> 02cc
    LVO -12  -> 02da
    LVO -18  -> 02f0
    LVO -24  -> 0336
    LVO -30  -> 03c8
    LVO -36  -> 03c6
    LVO -42  -> 03c6
    LVO -48  -> 03cc
    LVO -54  -> 1196
    LVO -60  -> 15f4
    LVO -66  -> 15d4
    LVO -72  -> 1964
    LVO -78  -> 1a0e
    LVO -84  -> 19f6
    LVO -90  -> 1888
    LVO -96  -> 189a
    LVO -102 -> 18ac
    LVO -108 -> 18be
    LVO -114 -> 18d0
    LVO -120 -> 18ec
    LVO -126 -> 1908
    LVO -132 -> 1924
    LVO -138 -> 1940
    LVO -144 -> 1952
    LVO -150 -> 1bdc
    LVO -156 -> 1bf6
    LVO -162 -> 1c08
    LVO -168 -> 1b6e
    LVO -174 -> 1bc4
    LVO -180 -> 2492
    LVO -186 -> 1c30
    LVO -192 -> 1746
    LVO -198 -> 1756
    LVO -204 -> 1838
    LVO -210 -> 184c
    LVO -216 -> 1630
    LVO -222 -> 1b0e
    LVO -228 -> 1776
    LVO -234 -> 1766
    LVO -240 -> 1796
    LVO -246 -> 1d62
    LVO -252 -> 03c6
    LVO -258 -> 1fa0
    LVO -264 -> 2248
    LVO -270 -> 1e3e
    LVO -276 -> 1e50
    LVO -282 -> 1676
    LVO -288 -> 03c6
    LVO -294 -> 1c64
    LVO -300 -> 225e
    LVO -306 -> 1c90
    LVO -312 -> 1cbe
    LVO -318 -> 1ce0
    LVO -324 -> 1d04
    LVO -330 -> 1d56
    LVO -336 -> 1e34
    LVO -342 -> 1e6a
    LVO -348 -> 1ee2
    LVO -354 -> 1f50
    LVO -360 -> 1ece
    LVO -366 -> 1f6c
    LVO -372 -> 03c6
    LVO -378 -> 03c6
    LVO -384 -> 03c6
    LVO -390 -> 296a
    LVO -396 -> 21fa
    LVO -402 -> 21ea
    LVO -408 -> 2200
    LVO -414 -> 21f2
    LVO -420 -> 2206
    LVO -426 -> 24d4
    LVO -432 -> 2e06
    LVO -438 -> 03c6
    LVO -444 -> 03c6
    LVO -450 -> 03c6
    LVO -456 -> 03c6
    LVO -462 -> 23d2
    LVO -468 -> 244a
    LVO -474 -> 21d8
    LVO -480 -> 21de
    LVO -486 -> 21e4
    LVO -492 -> 220e
    LVO -498 -> 21c6
    LVO -504 -> 21ce
    LVO -510 -> 03c6
    LVO -516 -> 03c6
    LVO -522 -> 22a6
    LVO -528 -> 2234
    LVO -534 -> 2214
    LVO -540 -> 22d8
    LVO -546 -> 22fc
    LVO -552 -> 231c
    LVO -558 -> 22c6
    LVO -564 -> 237e
    LVO -570 -> 233c
    LVO -576 -> 03c6
    LVO -582 -> 03c6
    LVO -588 -> 03c6
    LVO -594 -> 03c6
    LVO -600 -> 03c6
    LVO -606 -> 03c6
    LVO -612 -> 24ae
    LVO -618 -> 24b0
    LVO -624 -> 24d0
    LVO -630 -> 24d2
    LVO -636 -> 2500
    LVO -642 -> 25d0
    LVO -648 -> 265e
    LVO -654 -> 1690
    LVO -660 -> 2caa
    LVO -666 -> 2cec
    LVO -672 -> 2d56
    LVO -678 -> 2d9a
    LVO -684 -> 2dc2
    LVO -690 -> 1186
    LVO -696 -> 2e76
    LVO -702 -> 2f12
    LVO -708 -> 2fd2
    LVO -714 -> 232a
    LVO -720 -> 3056
    LVO -726 -> 30b6
    LVO -732 -> 3114
    LVO -738 -> 317e
    LVO -744 -> 31a6
    LVO -750 -> 3464
    LVO -756 -> 360c
    LVO -762 -> 362c

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
