---
type: Library
title: flyer_4.43.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:51.017314Z
---

# flyer_4.43.library

## Structure scan

```
romtag@1fda flags=80 ver=4 type=9 pri=0
  name[1ff4]='flyer.library' idstr[2067]='flyer.library 4.43  (18 Apr 1997)\r\n' init=20aa endskip=79ee
  inittab: datasize=9d6 functab@20ba datatab@21ea initfunc=220a
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
