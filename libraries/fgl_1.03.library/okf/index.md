---
type: Library
title: fgl_1.03.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:52.366294Z
---

# fgl_1.03.library

## Structure scan

```
romtag@84 flags=80 ver=1 type=9 pri=0
  name[4]='fgl.library' idstr[10]='$VER:1.03 fgl (23.10.96)' init=9e endskip=26a
  inittab: datasize=3f functab@ae datatab@15a initfunc=186
  functab: 3 vectors (abs-long)
    LVO -6   -> 01de
    LVO -12  -> 01ec
    LVO -18  -> 0200

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
