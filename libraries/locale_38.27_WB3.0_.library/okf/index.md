---
type: Library
title: locale_38.27(WB3.0).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:16.000944Z
---

# locale_38.27(WB3.0).library

## Structure scan

```
romtag@4 flags=80 ver=38 type=9 pri=0
  name[1e]='locale.library' idstr[2d]='locale 38.27 (2.6.92)\r\n' init=48 endskip=3cd0
  inittab: datasize=518 functab@58 datatab@a4 initfunc=c4
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
