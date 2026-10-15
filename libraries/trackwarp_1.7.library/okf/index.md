---
type: Library
title: trackwarp_1.7.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:40.410197Z
---

# trackwarp_1.7.library

## Structure scan

```
romtag@4 flags=80 ver=1 type=9 pri=0
  name[1e]='trackwarp.library' idstr[30]='trackwarp.library 1.7 [build 165] (18.12.2013)' init=e2 endskip=32ea
  inittab: datasize=36 functab@f2 datatab@10e initfunc=12e
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
