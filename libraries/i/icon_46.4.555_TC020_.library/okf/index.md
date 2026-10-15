---
type: Library
title: icon_46.4.555(TC020).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:28:05.051142Z
---

# icon_46.4.555(TC020).library

## Structure scan

```
romtag@2 flags=80 ver=51 type=9 pri=136
  name[390]='icon.library' idstr[3a2]='icon.library 51.4.555 (TC020)' init=1c endskip=8668
  inittab: datasize=2710 functab@2c datatab@74 initfunc=7e
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
