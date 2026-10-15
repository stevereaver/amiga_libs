---
type: Library
title: mmv8_22.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:04.863241Z
---

# mmv8_22.0.library

## Structure scan

```
romtag@4 flags=00 ver=22 type=9 pri=0
  name[1e]='mmv8.library' idstr[32]='mmv8.library 22.0 (22.9.2021)\r\n' init=74 endskip=20d0
  inittab: datasize=48e77f7e functab@2c780004 datatab@220841fa initfunc=e693c9

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
