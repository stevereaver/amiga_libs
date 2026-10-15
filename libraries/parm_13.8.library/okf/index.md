---
type: Library
title: parm_13.8.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:12.111882Z
---

# parm_13.8.library

## Structure scan

```
romtag@4 flags=80 ver=13 type=9 pri=0
  name[1f]='' idstr[0]='pÿNuJü' init=14c endskip=1e
  inittab: datasize=4aac0b00 functab@661843ec datatab@8c2c6c initfunc=aec7000

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
