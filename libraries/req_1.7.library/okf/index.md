---
type: Library
title: req_1.7.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T12:48:57.005805Z
---

# req_1.7.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[1e]='req.library' idstr[30]='NewReqLib 1.7 (29.7.97)\r\n' init=142 endskip=1c04
  inittab: datasize=78 functab@152 datatab@19e initfunc=1be
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
