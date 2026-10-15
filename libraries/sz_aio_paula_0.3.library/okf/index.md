---
type: Library
title: sz_aio_paula_0.3.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:50.693203Z
---

# sz_aio_paula_0.3.library

## Structure scan

```
romtag@4 flags=80 ver=0 type=9 pri=0
  name[254]='sz_aio_paula.library' idstr[269]='$VER: sz_aio_paula V0.3  17.11.2018  by Rainer Müller' init=1e endskip=146
  inittab: datasize=430 functab@1b4c datatab@2e initfunc=4e
  functab: 7 vectors (abs-long)
    LVO -6   -> 006e
    LVO -12  -> 00b8
    LVO -18  -> 00ec
    LVO -24  -> 012c
    LVO -30  -> 1b92
    LVO -36  -> 1baa
    LVO -42  -> 1bbe

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
