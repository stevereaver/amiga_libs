---
type: Library
title: memory_40.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:45.486900Z
---

# memory_40.1.library

## Structure scan

```
romtag@4 flags=80 ver=40 type=9 pri=0
  name[76b0]='memory.library' idstr[4]='Jü' init=2c endskip=1e
  inittab: datasize=242078 functab@43b7c datatab@280014 initfunc=3b7c0001

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
