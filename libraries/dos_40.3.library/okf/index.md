---
type: Library
title: dos_40.3.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:56.569032Z
---

# dos_40.3.library

## Structure scan

```
romtag@0 flags=00 ver=41 type=9 pri=136
  name[1152]='dos.library' idstr[80e0]='dos 41.0 (22.01.2012)\r\n' init=f86 endskip=80f8
  inittab: datasize=2c780004 functab@203c0000 datatab@3e441fa initfunc=daa93c9

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
