---
type: Library
title: bfbplayDIGI_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:45.248380Z
---

# bfbplayDIGI_1.0.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='bfbplayDIGI.library' idstr[32]='bfbplayDIGI.library V1.0 (18.07.1996)\r\n' init=bc endskip=8b4
  inittab: datasize=b2 functab@cc datatab@108 initfunc=128
  functab: 14 vectors (abs-long)
    LVO -6   -> 014a
    LVO -12  -> 0158
    LVO -18  -> 0172
    LVO -24  -> 01bc
    LVO -30  -> 01c0
    LVO -36  -> 040e
    LVO -42  -> 0498
    LVO -48  -> 04ea
    LVO -54  -> 0518
    LVO -60  -> 0544
    LVO -66  -> 0582
    LVO -72  -> 05b0
    LVO -78  -> 05bc
    LVO -84  -> 0620

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
