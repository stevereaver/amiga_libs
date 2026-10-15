---
type: Library
title: commodities_44.18(WB3.9).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:58.755934Z
---

# commodities_44.18(WB3.9).library

## Structure scan

```
romtag@4 flags=80 ver=44 type=9 pri=0
  name[24]='commodities.library' idstr[38]='commodities.library 44.18 (16.10.2000)\r\n' init=a0 endskip=1e
  inittab: datasize=70fe6028 functab@704093c9 datatab@61000936 initfunc=4a80671a

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
