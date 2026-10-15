---
type: Library
title: mmv88_7.04.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:18.384511Z
---

# mmv88_7.04.library

## Structure scan

```
romtag@4 flags=00 ver=7 type=9 pri=0
  name[1e]='mmv88.library' idstr[32]='mmv88.library 7.04 (2.5.2021)\r\n' init=72 endskip=60a6
  inittab: datasize=48e77f7e functab@2c780004 datatab@220841fa initfunc=de93c9

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
