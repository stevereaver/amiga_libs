---
type: Library
title: asl_1.6.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:22:06.015803Z
---

# asl_1.6.library

## Structure scan

```
romtag@4 flags=80 ver=39 type=9 pri=0
  name[1e]='asl.library' idstr[30]='NewAslLib 1.6 (8.8.97)\r\n' init=1ac endskip=2266
  inittab: datasize=ae functab@1bc datatab@1d4 initfunc=1f4
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
