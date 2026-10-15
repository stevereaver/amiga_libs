---
type: Library
title: frog_1.76(020).library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:22.304199Z
---

# frog_1.76(020).library

## Structure scan

```
romtag@88 flags=80 ver=1 type=9 pri=0
  name[a2]='frog.library' idstr[54]='frog.library 1.76 (31.03.03) [020] (c) Rafal Sanda' init=3e endskip=a2
  inittab: datasize=34 functab@a datatab@0 initfunc=cc
  functab: 3 vectors (abs-long)
    LVO -6   -> 0150
    LVO -12  -> 0168
    LVO -18  -> 0196

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
