---
type: Library
title: ixnet_48.0(040).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:54.259162Z
---

# ixnet_48.0(040).library

## Structure scan

```
romtag@4 flags=80 ver=48 type=9 pri=0
  name[1e]='ixnet.library' idstr[2c]='ixnet 48.0 [68040, amigaos] (14.7.98)\r\n' init=54 endskip=1e
  inittab: datasize=2c functab@64 datatab@228 initfunc=254
  functab: 112 vectors (abs-long)
    LVO -6   -> 026c
    LVO -12  -> 028e
    LVO -18  -> 02b4
    LVO -24  -> 0302
    LVO -30  -> 1e40
    LVO -36  -> 1e9a
    LVO -42  -> 1efc
    LVO -48  -> 1f4e
    LVO -54  -> 20ce
    LVO -60  -> 23a8
    LVO -66  -> 2130
    LVO -72  -> 21ae
    LVO -78  -> 2214
    LVO -84  -> 2272
    LVO -90  -> 22e4
    LVO -96  -> 234a
    LVO -102 -> 23c4
    LVO -108 -> 2416
    LVO -114 -> 247c
    LVO -120 -> 24e2
    LVO -126 -> 2540
    LVO -132 -> 259e
    LVO -138 -> 263a
    LVO -144 -> 26d6
    LVO -150 -> 2b26
    LVO -156 -> 29b8
    LVO -162 -> 323e
    LVO -168 -> 31ba
    LVO -174 -> 0dd8
    LVO -180 -> 0e36
    LVO -186 -> 0ea2
    LVO -192 -> 0f96
    LVO -198 -> 0002
    LVO -204 -> 0002
    LVO -210 -> 0002
    LVO -216 -> 0002
    LVO -222 -> 0002
    LVO -228 -> 0002
    LVO -234 -> 0002
    LVO -240 -> 0002
    LVO -246 -> 0002
    LVO -252 -> 1bf0
    LVO -258 -> 1cba
    LVO -264 -> 0002
    LVO -270 -> 0002
    LVO -276 -> 03aa
    LVO -282 -> 0404
    LVO -288 -> 0484
    LVO -294 -> 0558
    LVO -300 -> 05d2
    LVO -306 -> 0002
    LVO -312 -> 083a
    LVO -318 -> 0878
    LVO -324 -> 08fc
    LVO -330 -> 08be
    LVO -336 -> 094e
    LVO -342 -> 1134
    LVO -348 -> 1194
    LVO -354 -> 11de
    LVO -360 -> 0002
    LVO -366 -> 0002
    LVO -372 -> 0002
    LVO -378 -> 0002
    LVO -384 -> 058e
    LVO -390 -> 1d0c
    LVO -396 -> 0f22
    LVO -402 -> 13d2
    LVO -408 -> 1098
    LVO -414 -> 10de
    LVO -420 -> 2c34
    LVO -426 -> 2f00
    LVO -432 -> 0f5c
    LVO -438 -> 0c32
    LVO -444 -> 0d9a
    LVO -450 -> 0b3e
    LVO -456 -> 0b8e
    LVO -462 -> 0bec
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
    LVO -534 -> 1da4
    LVO -540 -> 1de8
    LVO -546 -> 2f8e
    LVO -552 -> 2ffa
    LVO -558 -> 3064
    LVO -564 -> 30b0
    LVO -570 -> 09b2
    LVO -576 -> 0a04
    LVO -582 -> 3114
    LVO -588 -> 07de
    LVO -594 -> 0002
    LVO -600 -> 0002
    LVO -606 -> 0002
    LVO -612 -> 0002
    LVO -618 -> 0002
    LVO -624 -> 0002
    LVO -630 -> 1d44
    LVO -636 -> 0002
    LVO -642 -> 0368
    LVO -648 -> 2bbc
    LVO -654 -> 1496
    LVO -660 -> 1fac
    LVO -666 -> 207a
    LVO -672 -> 200a

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
