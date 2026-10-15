---
type: Library
title: identify_12.0(020).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:32.750411Z
---

# identify_12.0(020).library

## Structure scan

```
romtag@4 flags=80 ver=12 type=9 pri=0
  name[1e]='identify.library' idstr[2f]='identify.library 12.0 (27.12.99)\r\n' init=aa endskip=28f8
  inittab: datasize=2c functab@ba datatab@ee initfunc=10e
  functab: 12 vectors (abs-long)
    LVO -6   -> 01e6
    LVO -12  -> 01f4
    LVO -18  -> 0208
    LVO -24  -> 028e
    LVO -30  -> 02f0
    LVO -36  -> 0cc6
    LVO -42  -> 0964
    LVO -48  -> 208a
    LVO -54  -> 0b94
    LVO -60  -> 1194
    LVO -66  -> 11de
    LVO -72  -> 1268

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
