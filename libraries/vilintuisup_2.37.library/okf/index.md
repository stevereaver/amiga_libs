---
type: Library
title: vilintuisup_2.37.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:22.651189Z
---

# vilintuisup_2.37.library

## Structure scan

```
romtag@4 flags=80 ver=2 type=9 pri=0
  name[4]='Jü' idstr[18]='' init=98 endskip=1e
  inittab: datasize=4eaefdd2 functab@294d0142 datatab@202c0142 initfunc=4cdf7800

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
