---
type: Library
title: akcc_gen0_37.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:22:05.334205Z
---

# akcc_gen0_37.1.library

## Structure scan

```
romtag@4 flags=80 ver=37 type=9 pri=1
  name[1e]='akcc_gen0.library' idstr[30]='akcc_gen0 37.1 (01.11.1993)\r\n' init=c2 endskip=c2
  inittab: datasize=2a functab@d2 datatab@132 initfunc=152
  functab: 4 vectors (abs-long)
    LVO -6   -> 01c6
    LVO -12  -> 01d4
    LVO -18  -> 01e8
    LVO -24  -> 0278

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
