---
type: Library
title: extra_4.649.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:20.915515Z
---

# extra_4.649.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=128
  name[1e]='extra.library' idstr[32]='extra.library 4.649 (08.09.06) Copyright © 1998-2006 RhoSigma, Roland Heyder\r\n' init=16c endskip=4506
  inittab: datasize=70 functab@17c datatab@2e0 initfunc=c02
  functab: 88 vectors (abs-long)
    LVO -6   -> 1174
    LVO -12  -> 11fc
    LVO -18  -> 1272
    LVO -24  -> 12c6
    LVO -30  -> 12ca
    LVO -36  -> 12ce
    LVO -42  -> 1304
    LVO -48  -> 131a
    LVO -54  -> 1330
    LVO -60  -> 1346
    LVO -66  -> 13fc
    LVO -72  -> 1466
    LVO -78  -> 15f4
    LVO -84  -> 1690
    LVO -90  -> 16e8
    LVO -96  -> 17b0
    LVO -102 -> 1828
    LVO -108 -> 18a6
    LVO -114 -> 193e
    LVO -120 -> 197a
    LVO -126 -> 19b4
    LVO -132 -> 1a46
    LVO -138 -> 1a72
    LVO -144 -> 1b12
    LVO -150 -> 1bf0
    LVO -156 -> 1c90
    LVO -162 -> 1d36
    LVO -168 -> 1d80
    LVO -174 -> 1dbe
    LVO -180 -> 1e16
    LVO -186 -> 1ec2
    LVO -192 -> 1efc
    LVO -198 -> 1f0c
    LVO -204 -> 1ff4
    LVO -210 -> 2086
    LVO -216 -> 2192
    LVO -222 -> 223e
    LVO -228 -> 234e
    LVO -234 -> 23a4
    LVO -240 -> 23fc
    LVO -246 -> 249a
    LVO -252 -> 256e
    LVO -258 -> 2674
    LVO -264 -> 278c
    LVO -270 -> 279a
    LVO -276 -> 27a2
    LVO -282 -> 27aa
    LVO -288 -> 2a0a
    LVO -294 -> 2ad6
    LVO -300 -> 134e
    LVO -306 -> 146e
    LVO -312 -> 1702
    LVO -318 -> 2f1c
    LVO -324 -> 2fa4
    LVO -330 -> 2fd8
    LVO -336 -> 3040
    LVO -342 -> 30ca
    LVO -348 -> 3158
    LVO -354 -> 31c0
    LVO -360 -> 321e
    LVO -366 -> 327e
    LVO -372 -> 32f4
    LVO -378 -> 330e
    LVO -384 -> 3312
    LVO -390 -> 3316
    LVO -396 -> 1a6e
    LVO -402 -> 1a3e
    LVO -408 -> 1a42
    LVO -414 -> 331a
    LVO -420 -> 331e
    LVO -426 -> 3322
    LVO -432 -> 3326
    LVO -438 -> 332a
    LVO -444 -> 332e
    LVO -450 -> 3332
    LVO -456 -> 3336
    LVO -462 -> 333a
    LVO -468 -> 333e
    LVO -474 -> 3342
    LVO -480 -> 3346
    LVO -486 -> 334a
    LVO -492 -> 334e
    LVO -498 -> 3352
    LVO -504 -> 3356
    LVO -510 -> 335a
    LVO -516 -> 335e
    LVO -522 -> 3362
    LVO -528 -> 3366

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
