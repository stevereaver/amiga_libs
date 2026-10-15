---
type: Library
title: xprymodem_2.20.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:49.073336Z
---

# xprymodem_2.20.library

## Structure scan

```
romtag@4 flags=00 ver=2 type=9 pri=0
  name[a1]='\x0e2.' idstr[b3]='_Nu' init=1e endskip=1e
  inittab: datasize=2f0b47f9 functab@5e datatab@26c826ce initfunc=43eb000c
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
