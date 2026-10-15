---
type: Library
title: barfly_1.117.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:19.347098Z
---

# barfly_1.117.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='barfly.library' idstr[2d]='assembler/keylibrary/barfly 1.117 30.5.96 © Ralph Schmidt 1994' init=6c endskip=3f0
  inittab: datasize=3c functab@7c datatab@a0 initfunc=110
  functab: 5 vectors (abs-long)
    LVO -6   -> 02cc
    LVO -12  -> 02da
    LVO -18  -> 02f0
    LVO -24  -> 0338
    LVO -30  -> 0344

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
