---
type: Library
title: ak_34.12.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:10.713173Z
---

# ak_34.12.library

## Structure scan

```
romtag@4 flags=80 ver=34 type=9 pri=12
  name[1e]='ak.library' idstr[29]='ak 34.12 (04. Oct 91)\r\n' init=70 endskip=70
  inittab: datasize=2a functab@80 datatab@f8 initfunc=124
  functab: 4 vectors (abs-long)
    LVO -6   -> 0198
    LVO -12  -> 01a6
    LVO -18  -> 01ba
    LVO -24  -> 025c

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
