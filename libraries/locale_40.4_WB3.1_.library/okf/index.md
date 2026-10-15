---
type: Library
title: locale_40.4(WB3.1).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:18.876765Z
---

# locale_40.4(WB3.1).library

## Structure scan

```
romtag@4 flags=80 ver=40 type=9 pri=0
  name[1e]='locale.library' idstr[2d]='locale 40.4 (16.8.93)\r\n' init=48 endskip=3e54
  inittab: datasize=51c functab@58 datatab@a4 initfunc=c4
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
