---
type: Library
title: dos_41.0(30.04.2012).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:51.703258Z
---

# dos_41.0(30.04.2012).library

## Structure scan

```
romtag@0 flags=00 ver=41 type=9 pri=136
  name[1140]='dos.library' idstr[7d00]='dos 41.0 (30.04.2012)\r\n' init=f74 endskip=7d18
  inittab: datasize=2c780004 functab@203c0000 datatab@3e441fa initfunc=d9893c9

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
