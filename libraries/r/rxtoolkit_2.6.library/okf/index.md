---
type: Library
title: rxtoolkit_2.6.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:31.630920Z
---

# rxtoolkit_2.6.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[0]='pÿNuJü' idstr[1e]='rxtoolkit.library 2.6 (15.5.2004)\r\n' init=44 endskip=224
  inittab: datasize=22 functab@54 datatab@ca initfunc=ec
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
