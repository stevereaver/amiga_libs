---
type: Library
title: rxwb_4.2.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:48.050744Z
---

# rxwb_4.2.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[36]='2004)\r\n' idstr[1e]='rxwb.library 4.2 (27.10.2004)\r\n' init=40 endskip=1f8
  inittab: datasize=22 functab@50 datatab@5e initfunc=98
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
