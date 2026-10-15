---
type: Library
title: decrunch_35.237.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:22.882140Z
---

# decrunch_35.237.library

## Structure scan

```
romtag@4 flags=80 ver=35 type=9 pri=0
  name[2e]='decrunch.library' idstr[3f]='DecrunchLib 35.237 (20.2.93) - LICENCEWARE © 1992,1993 by Georg Hörmann\r\n' init=1e endskip=68bc
  inittab: datasize=28 functab@c2 datatab@0 initfunc=8a
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
