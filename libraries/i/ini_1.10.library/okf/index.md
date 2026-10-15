---
type: Library
title: ini_1.10.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:20.910974Z
---

# ini_1.10.library

## Structure scan

```
romtag@4 flags=80 ver=33 type=9 pri=0
  name[1e]='ini.library' idstr[2a]='INI Lib Version 1.10 (v33) (09 Aug 01) by Sebastian Vater, known as Basty/Seasons.' init=80 endskip=0
  inittab: datasize=36 functab@90 datatab@12a initfunc=146
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
