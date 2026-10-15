---
type: Library
title: bfbplayOKTA_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:39.403203Z
---

# bfbplayOKTA_1.0.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='bfbplayOKTA.library' idstr[32]='bfbplayOKTA.library V1.0 (23.07.1996)\r\n' init=da endskip=100
  inittab: datasize=b2 functab@ea datatab@126 initfunc=146
  functab: 14 vectors (abs-long)
    LVO -6   -> 0168
    LVO -12  -> 0176
    LVO -18  -> 0190
    LVO -24  -> 01da
    LVO -30  -> 01de
    LVO -36  -> 03ea
    LVO -42  -> 046c
    LVO -48  -> 04de
    LVO -54  -> 0508
    LVO -60  -> 0514
    LVO -66  -> 0520
    LVO -72  -> 052c
    LVO -78  -> 0538
    LVO -84  -> 05c8

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
