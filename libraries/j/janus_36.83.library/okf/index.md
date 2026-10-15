---
type: Library
title: janus_36.83.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:19.009114Z
---

# janus_36.83.library

## Structure scan

```
romtag@36 flags=80 ver=36 type=9 pri=0
  name[24]='janus.library' idstr[4]='janus.library 36.83 (21.8.91)\r\n' init=a94 endskip=2780
  inittab: datasize=10c functab@efe datatab@0 initfunc=aa4
  functab: 40 vectors (abs-long)
    LVO -6   -> 113c
    LVO -12  -> 114a
    LVO -18  -> 1162
    LVO -24  -> 116c
    LVO -30  -> 0904
    LVO -36  -> 093a
    LVO -42  -> 09a8
    LVO -48  -> 09e8
    LVO -54  -> 0a10
    LVO -60  -> 0050
    LVO -66  -> 0134
    LVO -72  -> 04da
    LVO -78  -> 0476
    LVO -84  -> 052e
    LVO -90  -> 0a32
    LVO -96  -> 0a4c
    LVO -102 -> 0a8a
    LVO -108 -> 02d6
    LVO -114 -> 0428
    LVO -120 -> 055a
    LVO -126 -> 061a
    LVO -132 -> 123c
    LVO -138 -> 1c44
    LVO -144 -> 1f88
    LVO -150 -> 23d0
    LVO -156 -> 2480
    LVO -162 -> 2552
    LVO -168 -> 2698
    LVO -174 -> 26cc
    LVO -180 -> 2702
    LVO -186 -> 270e
    LVO -192 -> 0620
    LVO -198 -> 0720
    LVO -204 -> 06ca
    LVO -210 -> 078c
    LVO -216 -> 07a4
    LVO -222 -> 05c0
    LVO -228 -> 271c
    LVO -234 -> 274e
    LVO -240 -> 061a

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
