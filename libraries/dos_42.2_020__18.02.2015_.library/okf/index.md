---
type: Library
title: dos_42.2(020)(18.02.2015).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:54.181013Z
---

# dos_42.2(020)(18.02.2015).library

## Structure scan

```
romtag@0 flags=00 ver=42 type=9 pri=136
  name[117e]='dos.library' idstr[7f1a]='dos 42.2 (18.2.2015)\r\n' init=fb8 endskip=7f34
  inittab: datasize=2c780004 functab@203c0000 datatab@3e441fa initfunc=d8e93c9

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
