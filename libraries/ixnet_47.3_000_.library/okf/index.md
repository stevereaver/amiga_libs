---
type: Library
title: ixnet_47.3(000).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:59.808196Z
---

# ixnet_47.3(000).library

## Structure scan

```
romtag@4 flags=80 ver=47 type=9 pri=0
  name[1e]='ixnet.library' idstr[2c]='ixnet 47.3 [68000, amigaos] (15.3.98)\r\n' init=54 endskip=1e
  inittab: datasize=2c functab@64 datatab@228 initfunc=254
  functab: 112 vectors (abs-long)
    LVO -6   -> 026c
    LVO -12  -> 028e
    LVO -18  -> 02b4
    LVO -24  -> 0302
    LVO -30  -> 1ef6
    LVO -36  -> 1f50
    LVO -42  -> 1fb2
    LVO -48  -> 2004
    LVO -54  -> 2184
    LVO -60  -> 245e
    LVO -66  -> 21e6
    LVO -72  -> 2264
    LVO -78  -> 22ca
    LVO -84  -> 2328
    LVO -90  -> 239a
    LVO -96  -> 2400
    LVO -102 -> 247a
    LVO -108 -> 24cc
    LVO -114 -> 2532
    LVO -120 -> 2598
    LVO -126 -> 25f6
    LVO -132 -> 2654
    LVO -138 -> 26f4
    LVO -144 -> 2794
    LVO -150 -> 2bf6
    LVO -156 -> 2a7a
    LVO -162 -> 3328
    LVO -168 -> 32a6
    LVO -174 -> 0e3e
    LVO -180 -> 0e9c
    LVO -186 -> 0f08
    LVO -192 -> 0ffe
    LVO -198 -> 0002
    LVO -204 -> 0002
    LVO -210 -> 0002
    LVO -216 -> 0002
    LVO -222 -> 0002
    LVO -228 -> 0002
    LVO -234 -> 0002
    LVO -240 -> 0002
    LVO -246 -> 0002
    LVO -252 -> 1c96
    LVO -258 -> 1d6a
    LVO -264 -> 0002
    LVO -270 -> 0002
    LVO -276 -> 03ac
    LVO -282 -> 0406
    LVO -288 -> 0484
    LVO -294 -> 055e
    LVO -300 -> 05d8
    LVO -306 -> 0002
    LVO -312 -> 0854
    LVO -318 -> 0892
    LVO -324 -> 0916
    LVO -330 -> 08d8
    LVO -336 -> 0968
    LVO -342 -> 119c
    LVO -348 -> 1200
    LVO -354 -> 124a
    LVO -360 -> 0002
    LVO -366 -> 0002
    LVO -372 -> 0002
    LVO -378 -> 0002
    LVO -384 -> 0594
    LVO -390 -> 1dbe
    LVO -396 -> 0f8a
    LVO -402 -> 1464
    LVO -408 -> 1100
    LVO -414 -> 1146
    LVO -420 -> 2d08
    LVO -426 -> 2fea
    LVO -432 -> 0fc4
    LVO -438 -> 0c76
    LVO -444 -> 0e00
    LVO -450 -> 0b7e
    LVO -456 -> 0bce
    LVO -462 -> 0c30
    LVO -468 -> 0002
    LVO -474 -> 0002
    LVO -480 -> 0002
    LVO -486 -> 0002
    LVO -492 -> 0002
    LVO -498 -> 0002
    LVO -504 -> 0002
    LVO -510 -> 0002
    LVO -516 -> 0002
    LVO -522 -> 0002
    LVO -528 -> 0002
    LVO -534 -> 1e56
    LVO -540 -> 1e9c
    LVO -546 -> 307a
    LVO -552 -> 30e6
    LVO -558 -> 3150
    LVO -564 -> 319c
    LVO -570 -> 09d0
    LVO -576 -> 0a22
    LVO -582 -> 3200
    LVO -588 -> 07f6
    LVO -594 -> 0002
    LVO -600 -> 0002
    LVO -606 -> 0002
    LVO -612 -> 0002
    LVO -618 -> 0002
    LVO -624 -> 0002
    LVO -630 -> 1df6
    LVO -636 -> 0002
    LVO -642 -> 036a
    LVO -648 -> 2c92
    LVO -654 -> 152c
    LVO -660 -> 2062
    LVO -666 -> 2130
    LVO -672 -> 20c0

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
