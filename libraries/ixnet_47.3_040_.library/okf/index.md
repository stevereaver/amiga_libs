---
type: Library
title: ixnet_47.3(040).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:55.621226Z
---

# ixnet_47.3(040).library

## Structure scan

```
romtag@4 flags=80 ver=47 type=9 pri=0
  name[1e]='ixnet.library' idstr[2c]='ixnet 47.3 [68040, amigaos] (15.3.98)\r\n' init=54 endskip=1e
  inittab: datasize=2c functab@64 datatab@228 initfunc=254
  functab: 112 vectors (abs-long)
    LVO -6   -> 026c
    LVO -12  -> 028e
    LVO -18  -> 02b4
    LVO -24  -> 0302
    LVO -30  -> 1e52
    LVO -36  -> 1eac
    LVO -42  -> 1f0e
    LVO -48  -> 1f60
    LVO -54  -> 20e0
    LVO -60  -> 23ba
    LVO -66  -> 2142
    LVO -72  -> 21c0
    LVO -78  -> 2226
    LVO -84  -> 2284
    LVO -90  -> 22f6
    LVO -96  -> 235c
    LVO -102 -> 23d6
    LVO -108 -> 2428
    LVO -114 -> 248e
    LVO -120 -> 24f4
    LVO -126 -> 2552
    LVO -132 -> 25b0
    LVO -138 -> 264e
    LVO -144 -> 26ec
    LVO -150 -> 2b3c
    LVO -156 -> 29d0
    LVO -162 -> 3252
    LVO -168 -> 31ce
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
    LVO -252 -> 1c00
    LVO -258 -> 1cca
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
    LVO -390 -> 1d1e
    LVO -396 -> 0f34
    LVO -402 -> 13ee
    LVO -408 -> 10aa
    LVO -414 -> 10f0
    LVO -420 -> 2c48
    LVO -426 -> 2f14
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
    LVO -534 -> 1db6
    LVO -540 -> 1dfa
    LVO -546 -> 2fa2
    LVO -552 -> 300e
    LVO -558 -> 3078
    LVO -564 -> 30c4
    LVO -570 -> 09b4
    LVO -576 -> 0a06
    LVO -582 -> 3128
    LVO -588 -> 07e0
    LVO -594 -> 0002
    LVO -600 -> 0002
    LVO -606 -> 0002
    LVO -612 -> 0002
    LVO -618 -> 0002
    LVO -624 -> 0002
    LVO -630 -> 1d56
    LVO -636 -> 0002
    LVO -642 -> 0368
    LVO -648 -> 2bd0
    LVO -654 -> 14b4
    LVO -660 -> 1fbe
    LVO -666 -> 208c
    LVO -672 -> 201c

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
