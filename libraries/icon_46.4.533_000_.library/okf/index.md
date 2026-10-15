---
type: Library
title: icon_46.4.533(000).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:29.741739Z
---

# icon_46.4.533(000).library

## Structure scan

```
romtag@2 flags=80 ver=46 type=9 pri=136
  name[232]='icon.library' idstr[244]='icon.library 46.4.533 (68000)' init=1c endskip=6e04
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
