---
type: Library
title: softieee_40.3.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:35.162579Z
---

# softieee_40.3.library

## Structure scan

```
romtag@4 flags=80 ver=40 type=9 pri=0
  name[c0]='softieee.library' idstr[d7]='softieee 40.3 (27.11.2022)\r\n' init=1e endskip=5a0c
  inittab: datasize=d0 functab@46 datatab@2e initfunc=fe
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
