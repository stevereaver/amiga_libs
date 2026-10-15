---
type: Library
title: amarquee_54.0.library
description: >-
  Byte-identical reconstruction (verbatim hunk .s + fixup.py
  RELOC32 splice).  Structure/LVO map below is auto-decoded from
  the shipped binary.
timestamp: 2026-10-15T13:27:22.543247Z
---

# amarquee_54.0.library

## Structure scan

```
romtag@4 flags=00 ver=54 type=9 pri=0
  name[1e]='amarquee.library' idstr[3420]='amarquee.library 54.0 for AmiTCP (04.05.2002) (c)Håkan Parting & Jeremy Friesner\r\n' init=30 endskip=30
  inittab: datasize=2f0848e7 functab@3f3e2c79 datatab@4 initfunc=49f90000

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
