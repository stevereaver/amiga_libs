---
type: Library
title: mtool_2.20(FPU).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:23.092150Z
---

# mtool_2.20(FPU).library

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
    LVO -30  -> 182c
    LVO -36  -> 1896
    LVO -42  -> 18fc
    LVO -48  -> 1c12
    LVO -54  -> 1306
    LVO -60  -> 124a
    LVO -66  -> 12a8
    LVO -72  -> 15ae
    LVO -78  -> 03d0
    LVO -84  -> 040c
    LVO -90  -> 0360
    LVO -96  -> 02fc
    LVO -102 -> 051c
    LVO -108 -> 0590
    LVO -114 -> 0606
    LVO -120 -> 06c6
    LVO -126 -> 06fe
    LVO -132 -> 073a
    LVO -138 -> 0776
    LVO -144 -> 0808
    LVO -150 -> 0898
    LVO -156 -> 0950
    LVO -162 -> 09a0
    LVO -168 -> 0a48
    LVO -174 -> 196c
    LVO -180 -> 1f94
    LVO -186 -> 1fec
    LVO -192 -> 1600
    LVO -198 -> 1148
    LVO -204 -> 11ca
    LVO -210 -> 1214
    LVO -216 -> 1162
    LVO -222 -> 1488
    LVO -228 -> 1378
    LVO -234 -> 0a94
    LVO -240 -> 112a
    LVO -246 -> 10ec
    LVO -252 -> 02ba
    LVO -258 -> 02cc
    LVO -264 -> 02de
    LVO -270 -> 02ee
    LVO -276 -> 02dc
    LVO -282 -> 02ec
    LVO -288 -> 20cc
    LVO -294 -> 20e8
    LVO -300 -> 2112
    LVO -306 -> 213c
    LVO -312 -> 2190
    LVO -318 -> 21f2
    LVO -324 -> 225c
    LVO -330 -> 235a
    LVO -336 -> 23b6
    LVO -342 -> 23fa
    LVO -348 -> 2426

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
