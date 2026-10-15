---
type: Library
title: translator_37.1(WB2.04).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:15.589700Z
---

# translator_37.1(WB2.04).library

## Structure scan

```
romtag@0 flags=81 ver=37 type=9 pri=40
  name[1a]='translator.library' idstr[2d]='translator 37.1 (15.1.91)\r\n' init=72 endskip=2844
  inittab: datasize=2a functab@4c datatab@5a initfunc=82
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
