---
type: Library
title: commodities_38.11(WB2.1).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:22:01.512428Z
---

# commodities_38.11(WB2.1).library

## Structure scan

```
romtag@4 flags=80 ver=38 type=9 pri=0
  name[1e]='commodities.library' idstr[32]='commodities 38.11 (2.7.92)\r\n' init=50 endskip=1adc
  inittab: datasize=116 functab@60 datatab@b2 initfunc=d0
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
