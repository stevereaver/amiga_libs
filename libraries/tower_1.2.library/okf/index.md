---
type: Library
title: tower_1.2.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:52.034391Z
---

# tower_1.2.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='tower.library' idstr[32]='tower 1.2 (19.11.94) Copyright © 1994 Christoph Feck, TowerSystems' init=150 endskip=1e
  inittab: datasize=a4 functab@76 datatab@0 initfunc=1ac
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
