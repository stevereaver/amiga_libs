---
type: Library
title: render_40.8.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:39.288887Z
---

# render_40.8.library

## Structure scan

```
romtag@3a flags=80 ver=40 type=9 pri=0
  name[54]='render.library' idstr[c]='render.library 40.8 (30.03.2003) [68k, beta]' init=680 endskip=54
  inittab: datasize=58 functab@59c datatab@0 initfunc=546
  functab: 3 vectors (abs-long)
    LVO -6   -> 049a
    LVO -12  -> 04f0
    LVO -18  -> 0452

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
