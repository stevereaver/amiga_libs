---
type: Library
title: mtool_2.20.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:36.029035Z
---

# mtool_2.20.library

## Structure scan

```
romtag@4 flags=80 ver=35 type=9 pri=0
  name[1e]='mtool.library' idstr[2c]='ToolLibrary 2.20 03-Nov-1991\r\n' init=a2 endskip=2fa
  inittab: datasize=3a functab@b2 datatab@19e initfunc=1be
  functab: 58 vectors (abs-long)
    LVO -6   -> 0236
    LVO -12  -> 0244
    LVO -18  -> 0258
    LVO -24  -> 02b6
    LVO -30  -> 1a88
    LVO -36  -> 1af2
    LVO -42  -> 1b58
    LVO -48  -> 1fa4
    LVO -54  -> 1360
    LVO -60  -> 12a4
    LVO -66  -> 1302
    LVO -72  -> 1638
    LVO -78  -> 03d0
    LVO -84  -> 040c
    LVO -90  -> 0360
    LVO -96  -> 02fc
    LVO -102 -> 051c
    LVO -108 -> 0590
    LVO -114 -> 0606
    LVO -120 -> 06c6
    LVO -126 -> 06fe
    LVO -132 -> 074a
    LVO -138 -> 0796
    LVO -144 -> 0846
    LVO -150 -> 08f4
    LVO -156 -> 09aa
    LVO -162 -> 09fa
    LVO -168 -> 0aa2
    LVO -174 -> 1bc8
    LVO -180 -> 24c4
    LVO -186 -> 254a
    LVO -192 -> 168a
    LVO -198 -> 11a0
    LVO -204 -> 1224
    LVO -210 -> 126e
    LVO -216 -> 11ba
    LVO -222 -> 1504
    LVO -228 -> 13e4
    LVO -234 -> 0af0
    LVO -240 -> 1182
    LVO -246 -> 1144
    LVO -252 -> 02ba
    LVO -258 -> 02cc
    LVO -264 -> 02de
    LVO -270 -> 02ee
    LVO -276 -> 02dc
    LVO -282 -> 02ec
    LVO -288 -> 2620
    LVO -294 -> 263c
    LVO -300 -> 2666
    LVO -306 -> 2690
    LVO -312 -> 26e4
    LVO -318 -> 2746
    LVO -324 -> 27b0
    LVO -330 -> 28ae
    LVO -336 -> 290a
    LVO -342 -> 294e
    LVO -348 -> 297a

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
