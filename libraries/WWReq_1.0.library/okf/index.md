---
type: Library
title: WWReq_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:06.212027Z
---

# WWReq_1.0.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='WWReq.library' idstr[2c]='requester toolkit lib 1.0 (13 July 1990)\r\n' init=64 endskip=2490
  inittab: datasize=3c functab@74 datatab@d8 initfunc=104
  functab: 24 vectors (abs-long)
    LVO -6   -> 0232
    LVO -12  -> 0240
    LVO -18  -> 0256
    LVO -24  -> 02c2
    LVO -30  -> 036a
    LVO -36  -> 11b0
    LVO -42  -> 2178
    LVO -48  -> 235a
    LVO -54  -> 13ca
    LVO -60  -> 13ea
    LVO -66  -> 1466
    LVO -72  -> 1710
    LVO -78  -> 172e
    LVO -84  -> 1fda
    LVO -90  -> 1c88
    LVO -96  -> 1e0e
    LVO -102 -> 20a2
    LVO -108 -> 1cec
    LVO -114 -> 0ee6
    LVO -120 -> 1362
    LVO -126 -> 136c
    LVO -132 -> 21cc
    LVO -138 -> 226a
    LVO -144 -> 22e6

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
