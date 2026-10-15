---
type: Library
title: mathtrans_100.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:24:04.968380Z
---

# mathtrans_100.1.library

## Structure scan

```
romtag@4 flags=00 ver=100 type=9 pri=0
  name[15a]='mathtrans.library' idstr[16c]='mathtrans20  MFCombs 6/14/93\r\n' init=1e endskip=1e
  inittab: datasize=2f0b47f9 functab@13e datatab@26c826ce initfunc=43eb0004
  functab: 0 vectors (abs-long)

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
