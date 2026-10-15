---
type: Library
title: amigaguide_44.4(WB3.5).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:32.395593Z
---

# amigaguide_44.4(WB3.5).library

## Structure scan

```
romtag@4 flags=80 ver=44 type=9 pri=0
  name[1e]='amigaguide.library' idstr[31]='amigaguide 44.4 (13.4.99)\r\n' init=50 endskip=1e
  inittab: datasize=29a functab@60 datatab@aa initfunc=c0
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
