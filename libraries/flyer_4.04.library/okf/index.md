---
type: Library
title: flyer_4.04.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:22.329258Z
---

# flyer_4.04.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[1e]='flyer.library' idstr[8a]='flyer.library 4.04 (7 Jun 1995)\r\n' init=ca endskip=4856
  inittab: datasize=1116 functab@da datatab@1e2 initfunc=202
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
