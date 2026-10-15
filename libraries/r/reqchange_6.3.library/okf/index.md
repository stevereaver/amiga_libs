---
type: Library
title: reqchange_6.3.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:31.324481Z
---

# reqchange_6.3.library

## Structure scan

```
romtag@6 flags=80 ver=6 type=9 pri=246
  name[71]='reqchange.library' idstr[50]='reqchange.library 6.3 (1.4.96)\r\n' init=20 endskip=416
  inittab: datasize=586 functab@50f4 datatab@30 initfunc=198
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
