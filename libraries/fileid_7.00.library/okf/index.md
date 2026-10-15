---
type: Library
title: fileid_7.00.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:25:36.918424Z
---

# fileid_7.00.library

## Structure scan

```
romtag@4 flags=80 ver=7 type=9 pri=0
  name[1e]='FileID.library' idstr[2d]='FileID 7.00 (21.8.95)\r\n' init=46 endskip=5af4
  inittab: datasize=38 functab@56 datatab@82 initfunc=a2
  functab: 10 vectors (abs-long)
    LVO -6   -> 0130
    LVO -12  -> 015e
    LVO -18  -> 0172
    LVO -24  -> 01d8
    LVO -30  -> 01dc
    LVO -36  -> 01f2
    LVO -42  -> 03aa
    LVO -48  -> 0246
    LVO -54  -> 0204
    LVO -60  -> 020a

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
