---
type: Library
title: dignet13_4.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:48:56.327324Z
---

# dignet13_4.0.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[46]='dignet13.library' idstr[1e]='dignet13.library version 4.0 (11.07.97)' init=58 endskip=1b5c
  inittab: datasize=44 functab@68 datatab@150 initfunc=186
  functab: 57 vectors (abs-long)
    LVO -6   -> 01a0
    LVO -12  -> 01ae
    LVO -18  -> 01c2
    LVO -24  -> 0208
    LVO -30  -> 02bc
    LVO -36  -> 0434
    LVO -42  -> 0500
    LVO -48  -> 05b4
    LVO -54  -> 0630
    LVO -60  -> 066e
    LVO -66  -> 0710
    LVO -72  -> 0760
    LVO -78  -> 0798
    LVO -84  -> 0a34
    LVO -90  -> 0a50
    LVO -96  -> 0ad0
    LVO -102 -> 0a98
    LVO -108 -> 0b1c
    LVO -114 -> 0b2e
    LVO -120 -> 0c84
    LVO -126 -> 0c6e
    LVO -132 -> 0d9a
    LVO -138 -> 0f4e
    LVO -144 -> 0fdc
    LVO -150 -> 06a6
    LVO -156 -> 0ff8
    LVO -162 -> 0be8
    LVO -168 -> 103e
    LVO -174 -> 105c
    LVO -180 -> 107c
    LVO -186 -> 109a
    LVO -192 -> 10ba
    LVO -198 -> 10dc
    LVO -204 -> 1166
    LVO -210 -> 11cc
    LVO -216 -> 1236
    LVO -222 -> 128a
    LVO -228 -> 12b2
    LVO -234 -> 15ea
    LVO -240 -> 1646
    LVO -246 -> 16a2
    LVO -252 -> 16ec
    LVO -258 -> 170c
    LVO -264 -> 162c
    LVO -270 -> 160a
    LVO -276 -> 12fc
    LVO -282 -> 136a
    LVO -288 -> 139a
    LVO -294 -> 13fa
    LVO -300 -> 1428
    LVO -306 -> 14ba
    LVO -312 -> 1512
    LVO -318 -> 1544
    LVO -324 -> 157a
    LVO -330 -> 1592
    LVO -336 -> 15aa
    LVO -342 -> 15ca

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
