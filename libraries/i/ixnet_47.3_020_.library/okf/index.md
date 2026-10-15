---
type: Library
title: ixnet_47.3(020).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:54.949347Z
---

# ixnet_47.3(020).library

## Structure scan

```
romtag@4 flags=80 ver=47 type=9 pri=0
  name[1e]='ixnet.library' idstr[2c]='ixnet 47.3 [68020, amigaos] (15.3.98)\r\n' init=54 endskip=1e
  inittab: datasize=2c functab@64 datatab@228 initfunc=254
  functab: 112 vectors (abs-long)
    LVO -6   -> 026c
    LVO -12  -> 028e
    LVO -18  -> 02b4
    LVO -24  -> 0302
    LVO -30  -> 1e4c
    LVO -36  -> 1ea6
    LVO -42  -> 1f08
    LVO -48  -> 1f5a
    LVO -54  -> 20da
    LVO -60  -> 23b4
    LVO -66  -> 213c
    LVO -72  -> 21ba
    LVO -78  -> 2220
    LVO -84  -> 227e
    LVO -90  -> 22f0
    LVO -96  -> 2356
    LVO -102 -> 23d0
    LVO -108 -> 2422
    LVO -114 -> 2488
    LVO -120 -> 24ee
    LVO -126 -> 254c
    LVO -132 -> 25aa
    LVO -138 -> 2646
    LVO -144 -> 26e2
    LVO -150 -> 2b30
    LVO -156 -> 29c4
    LVO -162 -> 323c
    LVO -168 -> 31ba
    LVO -174 -> 0dea
    LVO -180 -> 0e48
    LVO -186 -> 0eb4
    LVO -192 -> 0fa8
    LVO -198 -> 0002
    LVO -204 -> 0002
    LVO -210 -> 0002
    LVO -216 -> 0002
    LVO -222 -> 0002
    LVO -228 -> 0002
    LVO -234 -> 0002
    LVO -240 -> 0002
    LVO -246 -> 0002
    LVO -252 -> 1bfa
    LVO -258 -> 1cc4
    LVO -264 -> 0002
    LVO -270 -> 0002
    LVO -276 -> 03aa
    LVO -282 -> 0404
    LVO -288 -> 0482
    LVO -294 -> 0554
    LVO -300 -> 05ce
    LVO -306 -> 0002
    LVO -312 -> 083c
    LVO -318 -> 087a
    LVO -324 -> 08fe
    LVO -330 -> 08c0
    LVO -336 -> 0950
    LVO -342 -> 1146
    LVO -348 -> 11a6
    LVO -354 -> 11f0
    LVO -360 -> 0002
    LVO -366 -> 0002
    LVO -372 -> 0002
    LVO -378 -> 0002
    LVO -384 -> 058a
    LVO -390 -> 1d18
    LVO -396 -> 0f34
    LVO -402 -> 13ee
    LVO -408 -> 10aa
    LVO -414 -> 10f0
    LVO -420 -> 2c3a
    LVO -426 -> 2f02
    LVO -432 -> 0f6e
    LVO -438 -> 0c3c
    LVO -444 -> 0dac
    LVO -450 -> 0b48
    LVO -456 -> 0b98
    LVO -462 -> 0bf6
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
    LVO -534 -> 1db0
    LVO -540 -> 1df4
    LVO -546 -> 2f90
    LVO -552 -> 2ffc
    LVO -558 -> 3066
    LVO -564 -> 30b2
    LVO -570 -> 09b4
    LVO -576 -> 0a06
    LVO -582 -> 3114
    LVO -588 -> 07e0
    LVO -594 -> 0002
    LVO -600 -> 0002
    LVO -606 -> 0002
    LVO -612 -> 0002
    LVO -618 -> 0002
    LVO -624 -> 0002
    LVO -630 -> 1d50
    LVO -636 -> 0002
    LVO -642 -> 0368
    LVO -648 -> 2bc4
    LVO -654 -> 14b4
    LVO -660 -> 1fb8
    LVO -666 -> 2086
    LVO -672 -> 2016

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
