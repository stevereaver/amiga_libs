---
type: Library
title: provision_35.40.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:38.252709Z
---

# provision_35.40.library

## Structure scan

```
romtag@4 flags=80 ver=35 type=9 pri=0
  name[1e]='provision.library' idstr[36]='provision.library 35.40 (1995-05-31)\r\n' init=14c endskip=7240
  inittab: datasize=2c functab@15c datatab@2f0 initfunc=310
  functab: 100 vectors (abs-long)
    LVO -6   -> 0442
    LVO -12  -> 0450
    LVO -18  -> 0464
    LVO -24  -> 0512
    LVO -30  -> 0a6c
    LVO -36  -> 0aa8
    LVO -42  -> 0ac2
    LVO -48  -> 0ad6
    LVO -54  -> 0aec
    LVO -60  -> 0b00
    LVO -66  -> 0b14
    LVO -72  -> 0bda
    LVO -78  -> 0ce0
    LVO -84  -> 12e6
    LVO -90  -> 16f2
    LVO -96  -> 171c
    LVO -102 -> 17da
    LVO -108 -> 184a
    LVO -114 -> 1752
    LVO -120 -> 17bc
    LVO -126 -> 1c04
    LVO -132 -> 1c1a
    LVO -138 -> 1c30
    LVO -144 -> 1c4a
    LVO -150 -> 1c64
    LVO -156 -> 1c7a
    LVO -162 -> 1c9e
    LVO -168 -> 1cac
    LVO -174 -> 1cde
    LVO -180 -> 1d24
    LVO -186 -> 1dce
    LVO -192 -> 1e08
    LVO -198 -> 1e2e
    LVO -204 -> 1e68
    LVO -210 -> 1eb4
    LVO -216 -> 1ed4
    LVO -222 -> 1f00
    LVO -228 -> 1f32
    LVO -234 -> 1f70
    LVO -240 -> 1fa2
    LVO -246 -> 1fea
    LVO -252 -> 2096
    LVO -258 -> 20f2
    LVO -264 -> 211a
    LVO -270 -> 2160
    LVO -276 -> 230c
    LVO -282 -> 23aa
    LVO -288 -> 23de
    LVO -294 -> 23fa
    LVO -300 -> 241a
    LVO -306 -> 2436
    LVO -312 -> 24d4
    LVO -318 -> 2558
    LVO -324 -> 257a
    LVO -330 -> 259e
    LVO -336 -> 25cc
    LVO -342 -> 25ea
    LVO -348 -> 2622
    LVO -354 -> 2638
    LVO -360 -> 265c
    LVO -366 -> 26a0
    LVO -372 -> 3390
    LVO -378 -> 0516
    LVO -384 -> 187c
    LVO -390 -> 2680
    LVO -396 -> 189c
    LVO -402 -> 18c0
    LVO -408 -> 1906
    LVO -414 -> 19a8
    LVO -420 -> 20d8
    LVO -426 -> 2104
    LVO -432 -> 1ccc
    LVO -438 -> 1a34
    LVO -444 -> 2452
    LVO -450 -> 2480
    LVO -456 -> 2dd0
    LVO -462 -> 2e76
    LVO -468 -> 2eb6
    LVO -474 -> 2ef4
    LVO -480 -> 2efa
    LVO -486 -> 2f0e
    LVO -492 -> 2172
    LVO -498 -> 21b6
    LVO -504 -> 13b8
    LVO -510 -> 6d8c
    LVO -516 -> 6e68
    LVO -522 -> 2f22
    LVO -528 -> 2f5c
    LVO -534 -> 2fa0
    LVO -540 -> 1a5e
    LVO -546 -> 1aa0
    LVO -552 -> 1ad2
    LVO -558 -> 0be4
    LVO -564 -> 0c3c
    LVO -570 -> 0c86
    LVO -576 -> 26f4
    LVO -582 -> 2748
    LVO -588 -> 08be
    LVO -594 -> 0910
    LVO -600 -> 1b20

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
