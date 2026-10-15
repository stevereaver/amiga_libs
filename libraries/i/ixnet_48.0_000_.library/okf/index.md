---
type: Library
title: ixnet_48.0(000).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:58.095045Z
---

# ixnet_48.0(000).library

## Structure scan

```
romtag@4 flags=80 ver=48 type=9 pri=0
  name[1e]='ixnet.library' idstr[2c]='ixnet 48.0 [68000, amigaos] (14.7.98)\r\n' init=54 endskip=1e
  inittab: datasize=2c functab@64 datatab@228 initfunc=254
  functab: 112 vectors (abs-long)
    LVO -6   -> 026c
    LVO -12  -> 028e
    LVO -18  -> 02b4
    LVO -24  -> 0302
    LVO -30  -> 1ed4
    LVO -36  -> 1f2e
    LVO -42  -> 1f90
    LVO -48  -> 1fe2
    LVO -54  -> 2162
    LVO -60  -> 243c
    LVO -66  -> 21c4
    LVO -72  -> 2242
    LVO -78  -> 22a8
    LVO -84  -> 2306
    LVO -90  -> 2378
    LVO -96  -> 23de
    LVO -102 -> 2458
    LVO -108 -> 24aa
    LVO -114 -> 2510
    LVO -120 -> 2576
    LVO -126 -> 25d4
    LVO -132 -> 2632
    LVO -138 -> 26d0
    LVO -144 -> 276e
    LVO -150 -> 2bca
    LVO -156 -> 2a52
    LVO -162 -> 32fc
    LVO -168 -> 327a
    LVO -174 -> 0e36
    LVO -180 -> 0e94
    LVO -186 -> 0f00
    LVO -192 -> 0ff6
    LVO -198 -> 0002
    LVO -204 -> 0002
    LVO -210 -> 0002
    LVO -216 -> 0002
    LVO -222 -> 0002
    LVO -228 -> 0002
    LVO -234 -> 0002
    LVO -240 -> 0002
    LVO -246 -> 0002
    LVO -252 -> 1c76
    LVO -258 -> 1d4a
    LVO -264 -> 0002
    LVO -270 -> 0002
    LVO -276 -> 03ac
    LVO -282 -> 0406
    LVO -288 -> 048a
    LVO -294 -> 056a
    LVO -300 -> 05e4
    LVO -306 -> 0002
    LVO -312 -> 085c
    LVO -318 -> 089a
    LVO -324 -> 091e
    LVO -330 -> 08e0
    LVO -336 -> 0970
    LVO -342 -> 1194
    LVO -348 -> 11f8
    LVO -354 -> 1242
    LVO -360 -> 0002
    LVO -366 -> 0002
    LVO -372 -> 0002
    LVO -378 -> 0002
    LVO -384 -> 05a0
    LVO -390 -> 1d9c
    LVO -396 -> 0f82
    LVO -402 -> 1450
    LVO -408 -> 10f8
    LVO -414 -> 113e
    LVO -420 -> 2cd8
    LVO -426 -> 2fc0
    LVO -432 -> 0fbc
    LVO -438 -> 0c76
    LVO -444 -> 0df8
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
    LVO -534 -> 1e34
    LVO -540 -> 1e7a
    LVO -546 -> 3050
    LVO -552 -> 30bc
    LVO -558 -> 3126
    LVO -564 -> 3172
    LVO -570 -> 09d8
    LVO -576 -> 0a2a
    LVO -582 -> 31d4
    LVO -588 -> 07fe
    LVO -594 -> 0002
    LVO -600 -> 0002
    LVO -606 -> 0002
    LVO -612 -> 0002
    LVO -618 -> 0002
    LVO -624 -> 0002
    LVO -630 -> 1dd4
    LVO -636 -> 0002
    LVO -642 -> 036a
    LVO -648 -> 2c62
    LVO -654 -> 1516
    LVO -660 -> 2040
    LVO -666 -> 210e
    LVO -672 -> 209e

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
