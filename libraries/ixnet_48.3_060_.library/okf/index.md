---
type: Library
title: ixnet_48.3(060).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:52.900747Z
---

# ixnet_48.3(060).library

## Structure scan

```
romtag@4 flags=80 ver=48 type=9 pri=0
  name[1e]='ixnet.library' idstr[2c]='ixnet 48.3 [68060, amigaos] (19.10.10)\r\n' init=56 endskip=1e
  inittab: datasize=2c functab@66 datatab@22a initfunc=256
  functab: 112 vectors (abs-long)
    LVO -6   -> 026e
    LVO -12  -> 0290
    LVO -18  -> 02b6
    LVO -24  -> 0304
    LVO -30  -> 1e16
    LVO -36  -> 1e70
    LVO -42  -> 1ed2
    LVO -48  -> 1f24
    LVO -54  -> 20a4
    LVO -60  -> 237e
    LVO -66  -> 2106
    LVO -72  -> 2184
    LVO -78  -> 21ea
    LVO -84  -> 2248
    LVO -90  -> 22ba
    LVO -96  -> 2320
    LVO -102 -> 239a
    LVO -108 -> 23ec
    LVO -114 -> 2452
    LVO -120 -> 24b8
    LVO -126 -> 2516
    LVO -132 -> 2574
    LVO -138 -> 2616
    LVO -144 -> 26b8
    LVO -150 -> 2af0
    LVO -156 -> 299a
    LVO -162 -> 31e6
    LVO -168 -> 3162
    LVO -174 -> 0dd8
    LVO -180 -> 0e36
    LVO -186 -> 0ea2
    LVO -192 -> 0f8e
    LVO -198 -> 0002
    LVO -204 -> 0002
    LVO -210 -> 0002
    LVO -216 -> 0002
    LVO -222 -> 0002
    LVO -228 -> 0002
    LVO -234 -> 0002
    LVO -240 -> 0002
    LVO -246 -> 0002
    LVO -252 -> 1bd0
    LVO -258 -> 1c9a
    LVO -264 -> 0002
    LVO -270 -> 0002
    LVO -276 -> 03aa
    LVO -282 -> 0400
    LVO -288 -> 0480
    LVO -294 -> 0554
    LVO -300 -> 05c6
    LVO -306 -> 0002
    LVO -312 -> 0832
    LVO -318 -> 086c
    LVO -324 -> 08f0
    LVO -330 -> 08b2
    LVO -336 -> 093e
    LVO -342 -> 1128
    LVO -348 -> 1188
    LVO -354 -> 11ce
    LVO -360 -> 0002
    LVO -366 -> 0002
    LVO -372 -> 0002
    LVO -378 -> 0002
    LVO -384 -> 0586
    LVO -390 -> 1cec
    LVO -396 -> 0f22
    LVO -402 -> 13c4
    LVO -408 -> 108c
    LVO -414 -> 10d2
    LVO -420 -> 2bfe
    LVO -426 -> 2eb6
    LVO -432 -> 0f58
    LVO -438 -> 0c28
    LVO -444 -> 0d9e
    LVO -450 -> 0b3c
    LVO -456 -> 0b88
    LVO -462 -> 0be6
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
    LVO -534 -> 1d80
    LVO -540 -> 1dc0
    LVO -546 -> 2f44
    LVO -552 -> 2fb0
    LVO -558 -> 3016
    LVO -564 -> 305e
    LVO -570 -> 09a2
    LVO -576 -> 09f0
    LVO -582 -> 30bc
    LVO -588 -> 07d6
    LVO -594 -> 0002
    LVO -600 -> 0002
    LVO -606 -> 0002
    LVO -612 -> 0002
    LVO -618 -> 0002
    LVO -624 -> 0002
    LVO -630 -> 1d20
    LVO -636 -> 0002
    LVO -642 -> 0368
    LVO -648 -> 2b86
    LVO -654 -> 1486
    LVO -660 -> 1f82
    LVO -666 -> 2050
    LVO -672 -> 1fe0

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
