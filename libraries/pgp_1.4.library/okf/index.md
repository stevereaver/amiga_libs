---
type: Library
title: pgp_1.4.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:53.245840Z
---

# pgp_1.4.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[5c]='pgp.library' idstr[68]='pgp.library 1.4 (26.01.02)' init=1e endskip=8e
  inittab: datasize=22 functab@84 datatab@2e initfunc=326c
  functab: 3 vectors (abs-long)
    LVO -6   -> 329c
    LVO -12  -> 32c2
    LVO -18  -> 32e2

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
