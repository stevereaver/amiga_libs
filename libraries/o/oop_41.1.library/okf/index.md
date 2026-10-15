---
type: Library
title: oop_41.1.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:24:47.718351Z
---

# oop_41.1.library

## Structure scan

```
romtag@ca flags=81 ver=41 type=9 pri=94
  name[be]='oop.library' idstr[9d]='oop.library 41.1 (23.02.2006) \r\n' init=e4 endskip=cb
  inittab: datasize=28c functab@3e datatab@f4 initfunc=0
  functab: 11 vectors (abs-long)
    LVO -6   -> 0010
    LVO -12  -> 001c
    LVO -18  -> 0028
    LVO -24  -> 0034
    LVO -30  -> 24dc
    LVO -36  -> 2588
    LVO -42  -> 1140
    LVO -48  -> 0fa0
    LVO -54  -> 0418
    LVO -60  -> 0fec
    LVO -66  -> 0480

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
