---
type: Library
title: icon_47.-1.573.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:32.110952Z
---

# icon_47.-1.573.library

## Structure scan

```
romtag@2 flags=80 ver=47 type=9 pri=136
  name[22e]='icon.library' idstr[240]='icon.library 47.-1.573 (68000)' init=1c endskip=7084
  inittab: datasize=b80 functab@2c datatab@74 initfunc=7e
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
