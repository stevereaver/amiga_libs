---
type: Library
title: fgl_4.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:21:58.421008Z
---

# fgl_4.0.library

## Structure scan

```
romtag@82 flags=80 ver=4 type=9 pri=0
  name[2]='fgl.library' idstr[e]='$VER:4.00 fgl (16.09.97)' init=9c endskip=26c
  inittab: datasize=3f functab@ac datatab@15c initfunc=188
  functab: 3 vectors (abs-long)
    LVO -6   -> 01e0
    LVO -12  -> 01ee
    LVO -18  -> 0202

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
