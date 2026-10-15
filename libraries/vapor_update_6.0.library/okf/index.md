---
type: Library
title: vapor_update_6.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:37.365796Z
---

# vapor_update_6.0.library

## Structure scan

```
romtag@4 flags=80 ver=5 type=9 pri=0
  name[1e04]='vapor_update.library' idstr[1e1c]='Vapor_Update 5.2 (18.11.1999) © by Oliver Wagner, All Rights Reserved' init=4 endskip=1e
  inittab: datasize=4afc0000 functab@40000 datatab@1e8005 initfunc=9000000

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
