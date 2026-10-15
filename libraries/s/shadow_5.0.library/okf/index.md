---
type: Library
title: shadow_5.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:26.626642Z
---

# shadow_5.0.library

## Structure scan

```
romtag@4 flags=00 ver=5 type=9 pri=0
  name[42e]='shadow.library' idstr[43d]='Shadow 5.0 (13.11.92) (C) David C. Navas\r\n' init=2d3e endskip=1e
  inittab: datasize=48e70102 functab@2e0823c7 datatab@252 initfunc=23fc0000

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
