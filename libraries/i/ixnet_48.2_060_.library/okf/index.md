---
type: Library
title: ixnet_48.2(060).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:53.919358Z
---

# ixnet_48.2(060).library

## Structure scan

```
romtag@4 flags=80 ver=48 type=9 pri=0
  name[1e]='ixnet.library' idstr[2c]='ixnet 48.2 [68060, amigaos] (6.4.1)\r\n' init=52 endskip=1e
  inittab: datasize=2c functab@62 datatab@226 initfunc=252
  functab: 112 vectors (abs-long)
    LVO -6   -> 026a
    LVO -12  -> 028c
    LVO -18  -> 02b2
    LVO -24  -> 0300
    LVO -30  -> 1e3c
    LVO -36  -> 1e96
    LVO -42  -> 1ef8
    LVO -48  -> 1f4a
    LVO -54  -> 20ca
    LVO -60  -> 23a4
    LVO -66  -> 212c
    LVO -72  -> 21aa
    LVO -78  -> 2210
    LVO -84  -> 226e
    LVO -90  -> 22e0
    LVO -96  -> 2346
    LVO -102 -> 23c0
    LVO -108 -> 2412
    LVO -114 -> 2478
    LVO -120 -> 24de
    LVO -126 -> 253c
    LVO -132 -> 259a
    LVO -138 -> 2636
    LVO -144 -> 26d2
    LVO -150 -> 2b22
    LVO -156 -> 29b4
    LVO -162 -> 323a
    LVO -168 -> 31b6
    LVO -174 -> 0dd4
    LVO -180 -> 0e32
    LVO -186 -> 0e9e
    LVO -192 -> 0f92
    LVO -198 -> 0002
    LVO -204 -> 0002
    LVO -210 -> 0002
    LVO -216 -> 0002
    LVO -222 -> 0002
    LVO -228 -> 0002
    LVO -234 -> 0002
    LVO -240 -> 0002
    LVO -246 -> 0002
    LVO -252 -> 1bec
    LVO -258 -> 1cb6
    LVO -264 -> 0002
    LVO -270 -> 0002
    LVO -276 -> 03a6
    LVO -282 -> 0400
    LVO -288 -> 0480
    LVO -294 -> 0554
    LVO -300 -> 05ce
    LVO -306 -> 0002
    LVO -312 -> 0836
    LVO -318 -> 0874
    LVO -324 -> 08f8
    LVO -330 -> 08ba
    LVO -336 -> 094a
    LVO -342 -> 1130
    LVO -348 -> 1190
    LVO -354 -> 11da
    LVO -360 -> 0002
    LVO -366 -> 0002
    LVO -372 -> 0002
    LVO -378 -> 0002
    LVO -384 -> 058a
    LVO -390 -> 1d08
    LVO -396 -> 0f1e
    LVO -402 -> 13ce
    LVO -408 -> 1094
    LVO -414 -> 10da
    LVO -420 -> 2c30
    LVO -426 -> 2efc
    LVO -432 -> 0f58
    LVO -438 -> 0c2e
    LVO -444 -> 0d96
    LVO -450 -> 0b3a
    LVO -456 -> 0b8a
    LVO -462 -> 0be8
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
    LVO -534 -> 1da0
    LVO -540 -> 1de4
    LVO -546 -> 2f8a
    LVO -552 -> 2ff6
    LVO -558 -> 3060
    LVO -564 -> 30ac
    LVO -570 -> 09ae
    LVO -576 -> 0a00
    LVO -582 -> 3110
    LVO -588 -> 07da
    LVO -594 -> 0002
    LVO -600 -> 0002
    LVO -606 -> 0002
    LVO -612 -> 0002
    LVO -618 -> 0002
    LVO -624 -> 0002
    LVO -630 -> 1d40
    LVO -636 -> 0002
    LVO -642 -> 0364
    LVO -648 -> 2bb8
    LVO -654 -> 1492
    LVO -660 -> 1fa8
    LVO -666 -> 2076
    LVO -672 -> 2006

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
