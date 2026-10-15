---
type: Library
title: muipop_19.10.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:23:46.961677Z
---

# muipop_19.10.library

## Structure scan

```
romtag@54 flags=00 ver=19 type=9 pri=0
  name[4]='muipop.library' idstr[19]='muipop.library 19.10 (12.02.97) ©1992-1997 Stefan Stuntz\r\n' init=ee endskip=6e
  inittab: datasize=48e72036 functab@24082a78 datatab@441f9 initfunc=34d8

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
