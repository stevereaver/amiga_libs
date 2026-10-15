---
type: Library
title: serio-comic_5.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:35.527976Z
---

# serio-comic_5.0.library

## Structure scan

```
romtag@4 flags=80 ver=5 type=9 pri=0
  name[1e]='serio-comic.library' idstr[32]='serio-comic.library v5.0 (28 Oct 1997)\r\n' init=82 endskip=82
  inittab: datasize=190 functab@92 datatab@14e initfunc=180
  functab: 46 vectors (abs-long)
    LVO -6   -> 056a
    LVO -12  -> 064c
    LVO -18  -> 0666
    LVO -24  -> 06a8
    LVO -30  -> 0c72
    LVO -36  -> 0ccc
    LVO -42  -> 0d04
    LVO -48  -> 0d74
    LVO -54  -> 0dba
    LVO -60  -> 0dfc
    LVO -66  -> 1170
    LVO -72  -> 1056
    LVO -78  -> 1156
    LVO -84  -> 11ca
    LVO -90  -> 138c
    LVO -96  -> 157c
    LVO -102 -> 15b0
    LVO -108 -> 196e
    LVO -114 -> 158c
    LVO -120 -> 15a0
    LVO -126 -> 1924
    LVO -132 -> 1c3a
    LVO -138 -> 1d68
    LVO -144 -> 20f4
    LVO -150 -> 2136
    LVO -156 -> 2178
    LVO -162 -> 2194
    LVO -168 -> 21ce
    LVO -174 -> 21e8
    LVO -180 -> 2202
    LVO -186 -> 21a4
    LVO -192 -> 1d86
    LVO -198 -> 1ddc
    LVO -204 -> 1e98
    LVO -210 -> 1f62
    LVO -216 -> 1f72
    LVO -222 -> 2090
    LVO -228 -> 0ec0
    LVO -234 -> 0e2e
    LVO -240 -> 1584
    LVO -246 -> 1d2a
    LVO -252 -> 20aa
    LVO -258 -> 21b4
    LVO -264 -> 20b2
    LVO -270 -> 20b8
    LVO -276 -> 13ea

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
