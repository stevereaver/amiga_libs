---
type: Library
title: 6581sid_1.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:00.144333Z
---

# 6581sid_1.1.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='6581sid.library' idstr[2e]='6581 SID Library V1.1 (2 Aug. 1993)\r\n' init=54 endskip=3d62
  inittab: datasize=2c functab@64 datatab@a0 initfunc=cc
  functab: 14 vectors (abs-long)
    LVO -6   -> 00dc
    LVO -12  -> 00ea
    LVO -18  -> 0100
    LVO -24  -> 013e
    LVO -30  -> 0578
    LVO -36  -> 08c2
    LVO -42  -> 096c
    LVO -48  -> 088a
    LVO -54  -> 0258
    LVO -60  -> 0874
    LVO -66  -> 0250
    LVO -72  -> 026c
    LVO -78  -> 0340
    LVO -84  -> 032e

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
