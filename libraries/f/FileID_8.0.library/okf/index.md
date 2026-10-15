---
type: Library
title: FileID_8.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:14.945248Z
---

# FileID_8.0.library

## Structure scan

```
romtag@4 flags=80 ver=8 type=9 pri=0
  name[1e]='FileID.library' idstr[2d]='FileID 8.0 (9.7.98)' init=68 endskip=626c
  inittab: datasize=38 functab@78 datatab@a4 initfunc=c4
  functab: 10 vectors (abs-long)
    LVO -6   -> 0154
    LVO -12  -> 0182
    LVO -18  -> 0196
    LVO -24  -> 01fc
    LVO -30  -> 0200
    LVO -36  -> 0216
    LVO -42  -> 03ce
    LVO -48  -> 026a
    LVO -54  -> 0228
    LVO -60  -> 022e

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
