---
type: Library
title: vlab_10.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:21.253375Z
---

# vlab_10.0.library

## Structure scan

```
romtag@4 flags=80 ver=10 type=9 pri=0
  name[1e]='vlab.library' idstr[2b]='vlab 10.0 (04.04.96)\r\n' init=d2 endskip=2f2
  inittab: datasize=fc functab@e2 datatab@132 initfunc=186
  functab: 19 vectors (abs-long)
    LVO -6   -> 022c
    LVO -12  -> 023a
    LVO -18  -> 0250
    LVO -24  -> 02ee
    LVO -30  -> 02f4
    LVO -36  -> 1360
    LVO -42  -> 0ac8
    LVO -48  -> 0342
    LVO -54  -> 2260
    LVO -60  -> 27c2
    LVO -66  -> 0a9c
    LVO -72  -> 03d4
    LVO -78  -> 03e4
    LVO -84  -> 0398
    LVO -90  -> 03b8
    LVO -96  -> 02ee
    LVO -102 -> 02ee
    LVO -108 -> 02ee
    LVO -114 -> 02ee

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
