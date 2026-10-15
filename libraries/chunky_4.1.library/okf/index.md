---
type: Library
title: chunky_4.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:33.833746Z
---

# chunky_4.1.library

## Structure scan

```
romtag@4 flags=80 ver=4 type=9 pri=0
  name[4fc]='?' idstr[50c]='?' init=1e endskip=4e
  inittab: datasize=62 functab@410 datatab@2e initfunc=50

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
