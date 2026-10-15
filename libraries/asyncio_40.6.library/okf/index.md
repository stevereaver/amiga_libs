---
type: Library
title: asyncio_40.6.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:59.131728Z
---

# asyncio_40.6.library

## Structure scan

```
romtag@4 flags=80 ver=40 type=9 pri=0
  name[f4]='Sn' idstr[104]='g' init=1e endskip=4e
  inittab: datasize=22 functab@78 datatab@2e initfunc=50
  functab: 1 vectors (abs-long)
    LVO -6   -> 017c

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
