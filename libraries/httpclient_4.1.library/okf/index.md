---
type: Library
title: httpclient_4.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:31.092615Z
---

# httpclient_4.1.library

## Structure scan

```
romtag@6884 flags=80 ver=4 type=9 pri=0
  name[67f4]='httpclient.library' idstr[685f]='ttpclient.library 4.1 (07.08.2023)' init=6808 endskip=689e
  inittab: datasize=5e functab@6818 datatab@0 initfunc=6594
  functab: 15 vectors (abs-long)
    LVO -6   -> 65c4
    LVO -12  -> 66d4
    LVO -18  -> 6790
    LVO -24  -> 67f0
    LVO -30  -> 68f0
    LVO -36  -> 69dc
    LVO -42  -> 6a18
    LVO -48  -> 6a28
    LVO -54  -> 6a54
    LVO -60  -> 6a64
    LVO -66  -> 6a84
    LVO -72  -> 6a90
    LVO -78  -> 6b54
    LVO -84  -> 6c3c
    LVO -90  -> 6c60

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
