---
type: Library
title: i2csensors_2.4.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:50.087315Z
---

# i2csensors_2.4.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[4]='Jü' idstr[0]='p' init=74 endskip=1e
  inittab: datasize=102b0018 functab@224a2c6d datatab@547201 initfunc=4eaeffca

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
