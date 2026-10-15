---
type: Library
title: ScreenSupport_1.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:20.579032Z
---

# ScreenSupport_1.0.library

## Structure scan

```
romtag@0 flags=00 ver=2 type=9 pri=0
  name[3454]='ScreenSupport.library' idstr[346a]='ScreenSupport.library 1.0 (27.9.97)' init=3740 endskip=1a
  inittab: datasize=4e550000 functab@2f0e2f0a datatab@220823ce initfunc=50

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
