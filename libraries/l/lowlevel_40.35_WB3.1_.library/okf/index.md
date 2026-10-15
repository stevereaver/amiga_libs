---
type: Library
title: lowlevel_40.35(WB3.1).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:06:27.621239Z
---

# lowlevel_40.35(WB3.1).library

## Structure scan

```
romtag@8 flags=81 ver=40 type=9 pri=1
  name[44e]='lowlevel.library' idstr[45f]='lowlevel 40.35 (30.7.93)\r\n' init=22 endskip=1a9c
  inittab: datasize=1fc functab@32 datatab@6c initfunc=78
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
